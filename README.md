# serene-builder

あなたのコンピュータに SereneLinux をインストールするための ISO イメージを作成します。

### 構成

SereneLinuxのnspawnコンテナのマシンA
Ubuntu18.04のdockerコンテナのマシンB
Debian 10のホストマシン
の場合とします。

#### 1. ホスト側の準備

- ホストマシンに名前付きパイプを作成します。
ここでは/var/lib/serenebuilder/pipe_slとします。

- ホストにパイプ処理用のスクリプトを作成します。以下、例です。

/usr/share/serenebuilder/pipe.sh

```bash
COMMAND=$(cat pipe_sl)
# パイプに"dist"を渡すとisoのビルド
#バージョンを渡すとbase-filesのビルドになります
if [[ $COMMAND == dist ]]; then
    buildiso # goto function buildiso()
else
    VERSION=$COMMAND
    buildbase-files # goto function buildbase-files()
fi
...#buildiso関数とbuildbase-files関数を作ります
```

serene-builder.service

```systemd
[Unit]
Description=serene-builder pipe
After=systemd-nspawn@serenelinux.service
Requires=systemd-nspawn@serenelinux.service

[Service]
ExecStart=/usr/share/serenebuilder/pipe.sh
Restart=always
```


#### 2. マシンAの準備

- マシンAを起動させます。
共有するディレクトリ

  - /var/lib/serenebuilder/share:/home/serene/share
  - /var/lib/serenebuilder/pipe_sl:/tmp/pipe_sl

- マシンAに通信用のスクリプトを作ります。

```bash
echo $(~/serene-devtools/get-version) > /tmp/pipe_sl
if [[ "$(cat /tmp/pipe_sl)" == error ]]; then
    echo "Error!\ncannot build base-files.deb" 1>&2; exit 1
fi

apt-get -y install ~/share/base-files-*
mv base-files-* /srv/www

~/serene-devtools/make-installlist.py > ~/share/install_list
rsync -av /etc/ ~/share/rootfs/etc
rsync -av /var/ ~/share/rootfs/var
~/serene-devtools/personaldaterremover.py

echo "1" > /tmp/pipe_sl #Send request about build iso
if [[ "$(cat /tmp/pipe_sl)" == error ]]; then
    echo "Error!\ncannot dist iso" 1>&2; exit 1
fi
```

#### 3.マシンBの準備

- Ubuntu18.04 bionicのコンテナを用意します。
- 今回はDockerを使用します。

Dockerfile

```docker
FROM ubuntu:18.04
RUN apt-get update \
&& apt-get -y upgrade \
COPY base-files-10.1ubuntu2.7
```
COMMAND=$(cat /var/lib/serenebuilder/pipe_sl)
#if send "dist" then build iso image,
#else send serenelinux's version then build base-files
$SHARE="$share"
if [[ $COMMAND == 1[0-9] ]]; then
    case $COMMAND in
        10 ) buildiso ;; #goto function buildiso()
        11 ) buildiso clean ;; #goto function buildiso(clean)
    esac
elif [[ $COMMAND == [0-9][0-9]q[1-4].[0-9].[0-9].[0-9] ]]; then
    VERSION=$COMMAND
    buildbase-files # goto function buildbase-files()
else
    echo "error" > /var/lib/serenebuilder/pipe_sl
fi

function buildbase-files() {
    BASE_FILES="base-files-10.1ubuntu2.7"
    cp -r /usr/share/serenebuilder/${BASE_FILES} /tmp
    echo "SereneLinux ${VERSION} \n \l" > /tmp/${BASE_FILES}/etc/issue
    echo "SereneLinux ${VERSION}" > /tmp/${BASE_FILES}/etc/issue.net
    sed -i"" -e s/'DISTRIB_DESCRIPTION=.*'/DISTRIB_DESCRIPTION=\"SereneLinux${VERSION}\"/g /tmp/${BASE_FILES}/etc/lsb-release
    sed -i"" -e s/'PRETTY_NAME=.*'/PRETTY_NAME=\"SereneLinux${VERSION}\"/g /tmp/${BASE_FILES}/etc/os-release

cd /tmp/${BASE_FILES}
dch -v "${BASE_FILES:11}serene${VERSION:5}"
debuild -us -uc
cd ..
apt-get install -y --allow-downgrades  ./${BASE_FILES}.deb

}

function buildiso(){
    $ROOTFS="$share/rootfs"
    if [[ $1 == clean ]]; then
        [ -d $ROOTFS ] && rm -rf $ROOTFS && mkdir $ROOTFS
        debootstrap bionic $ROOTFS http://ftp.jaist.ac.jp/pub/Linux/ubuntu
    fi
    
    cp $ROOTFS/$(readlink $ROOTFS/vmlinuz) 
}

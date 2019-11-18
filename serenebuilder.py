#!/usr/bin/env python3
import configparser
import os
import errno


class Makedockerfile():
    def __init__(self):
        pass

    def readconfig(self):
        config = configparser.ConfigParser()
        path = '/home/ksmt/git/serene-builder/serenebuilder.conf'
        if not os.path.exists(path):
            raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), path)
        config.read(path, encoding='utf-8')
        # get var
        installpackages = config.get('DEFAULT', 'Install')
        copieddirectory = config.get('DEFAULT', 'Copieddir')
        print(installpackages)

if __name__ == "__main__":
    make = Makedockerfile()
    make.readconfig()
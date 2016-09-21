#!/bin/bash

set -e

rm -fv /etc/apt/sources.list.d/pve-enterprise.list
apt-get install quilt

rsync -axvP files/ /

if ! date | grep -q EDT
then
    dpkg-reconfigure tzdata locales
fi

apt-get update
apt-get dist-upgrade


apt-get install -y \
htop \
quilt \
curl \
tree \
ncdu \
pv \

znapzendVer=0.15.7

if [ ! -e /opt/znapzend-$znapzendVer ]
then
{
	apt-get install build-essential
	TMPDIR=$(mktemp -d)
	trap 'rm -rf $TMPDIR' EXIT

	rm -rf /opt/znapzend-*

	cd $TMPDIR
	wget https://github.com/oetiker/znapzend/releases/download/v$znapzendVer/znapzend-$znapzendVer.tar.gz
	tar zxvf znapzend-$znapzendVer.tar.gz
	cd znapzend-$znapzendVer
	./configure --prefix=/opt/znapzend-$znapzendVer

	make install

	for x in /opt/znapzend-$znapzendVer/bin/*
	do
		ln -s $x /usr/local/bin
	done

	cd -
}
fi

cd /root/proxpatches
./post-apt-patch.sh

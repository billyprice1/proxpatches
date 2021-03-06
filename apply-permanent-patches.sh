#!/bin/bash

set -e

rm -fv /etc/apt/sources.list.d/pve-enterprise.list
apt-get install quilt

rsync -axvP files/ /

if ! date | grep -q EDT
then
    dpkg-reconfigure tzdata
fi

sed -i 's/^\# en_CA.UTF-8/en_CA.UTF-8/' /etc/locale.gen
locale-gen

apt-get update
apt-get dist-upgrade -y


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
	apt-get install -y build-essential
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

	cp init/znapzend.service /etc/systemd/system/
	systemctl enable znapzend.service
	systemctl start znapzend.service

	cd -
}
fi

cd /root/proxpatches
./post-apt-patch.sh

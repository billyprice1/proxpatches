#!/bin/bash

rm -fiv /etc/apt/sources.list.d/pve-enterprise.list
apply-permanent-patches.sh

apt-get update
apt-get dist-upgrade

dpkg-reconfigure tzdata locales

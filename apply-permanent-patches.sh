#!/bin/bash

apt-get install -y \
htop \
quilt \
curl \
tree \
ncdu \
pv \

rsync -axvP files/ /

./post-apt-patch.sh

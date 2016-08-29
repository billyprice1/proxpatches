#!/bin/bash

apt-get install -y htop quilt

rsync -axvP files/ /

./post-apt-patch.sh

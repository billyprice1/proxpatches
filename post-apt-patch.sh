#!/bin/bash -e

cd $(dirname $(realpath $0))

./mountrootfs

trap 'umount ./rootfs' EXIT

quilt push -a

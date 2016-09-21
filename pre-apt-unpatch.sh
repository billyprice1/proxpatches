#!/bin/bash -e

which quilt > /dev/null || exit 0

cd $(dirname $(realpath $0))

./mountrootfs

trap 'umount ./rootfs' EXIT

quilt pop -a

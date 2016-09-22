#!/bin/bash

set -e

echo "Stopping dockerd..."

# stop dockerd if running
! pidof dockerd &>/dev/null || service docker stop

if zfs list -r -H -o mountpoint | grep -q /var/lib/docker
then
	echo "docker zfs dataset already exists, skipping."
else
	echo "Creating zfs dataset for docker"

	rm --interactive=once -rf /var/lib/docker
	zfs create \
		-o sync=disabled \
		-o mountpoint=/var/lib/docker \
		-o com.sun:auto-snapshot=false \
		rpool/docker
fi

mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/zfs-storage.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -s zfs
EOF

cat > /etc/systemd/system/docker.service.d/xxnice.conf <<EOF
[Service]
Nice=19
IOSchedulingClass=3
IOSchedulingPriority=7
CPUSchedulingPolicy=idle
CPUSchedulingPriority=10
EOF

# make systemd consider this new file
systemctl daemon-reload

if ! dpkg -s docker-engine &>/dev/null
then
	curl -sSL https://get.docker.com/ | sh
fi

# start dockerd if not running
pidof dockerd &>/dev/null || service docker start

docker info | grep "Storage Driver: zfs"

echo "All done OK."

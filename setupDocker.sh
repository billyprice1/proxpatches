#!/bin/bash

set -e

if [[ $(zfs list -H -o mountpoint rpool/docker 2>/dev/null) != /var/lib/docker ]]
then
	echo "Creating zfs dataset for docker"
	# stop dockerd if running
	! pidof dockerd &>/dev/null || service docker stop

	rm --interactive=once -rf /var/lib/docker
	zfs create -o sync=disabled -o mountpoint=/var/lib/docker rpool/docker
else
	echo "docker zfs dataset already exists, skipping."
fi


if ! dpkg -s docker-engine &>/dev/null
then
	curl -sSL https://get.docker.com/ | sh
fi

# start dockerd if not running
pidof dockerd &>/dev/null || service docker start

if ! docker info | grep "Storage Driver: zfs"
then
	! pidof dockerd || service docker stop

	mkdir /etc/systemd/system/docker.service.d
	cat > /etc/systemd/system/docker.service.d/zfs-storage.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -s zfs
EOF

	# make systemd consider this new file
	systemctl daemon-reload

	service docker start
	docker info |grep "Storage Driver: zfs"
fi

echo "All done OK."

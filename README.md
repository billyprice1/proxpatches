This repo contains patches we maintain on top of the vanilla Proxmox installation.

# Initial setup
## Pre-requisites
```
cat ~/.ssh/id_rsa.pub | ssh root@proxsrv "cat >> .ssh/authorized_keys"
ssh root@proxsrv
sed -i 's!ftp\.ca\.debian\.org!httpredir.debian.org!' /etc/apt/sources.list
apt-get update
apt-get install git
```

clone this repo to the proxmox system and do first time init.

As root on the system:

```
cd /root # clone must be here, assumption in some files
git clone http://gitlab.sonatest.net/it/proxpatches.git
cd proxpatches
./apply-permanent-patches.sh
```

# Adding files in non-apt managed directories
Simply reproduce the directory tree leading to the new file under ./files then
add your new file. To apply this new file to the system's rootfs, run ./apply-permanent-patches.sh
again.

# Patching apt-managed files (like /usr/...)
```
cd /root/proxpatches
./mountrootfs # does a mount --bind of / to ./rootfs (needed for quilt to work)
quilt new name-of-my-patch.patch
quilt add rootfs/path/to/the/file/to/patch.ext
```
Now edit the file and make it as you want it. Then:
```
quilt refresh
```
Now you can leave the system patched like this, or unapply the patch by doing `quilt pop`.
Either way, you now have the patch ready to commit in this repo. Inspect your patch, commit
and push it to origin.

# Updating an already patched system
You can run ./apply-permanent patches as many times as you want. If 'origin' has
a new proxpatches version, simply:
```
cd /root/proxpatches
git pull
./apply-permanent-patches.sh
```


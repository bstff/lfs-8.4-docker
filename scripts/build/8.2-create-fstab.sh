#!/bin/bash
set -e
echo "Creating fstab.."

# 8.2 Creating /etc/fstab
cat > /etc/fstab <<"EOF"
# file system   mount-point   type      options               dump  fsck
#                                                                   order
# /dev/sda3     /             ext4      defaults              1     1  # 根分区
# /dev/sda2     /boot         ext2      defaults              1     1  # boot分区
# /dev/sda4     /home         ext4      defaults              1     1  # home分区

/dev/ram        /             auto      defaults              1     1
proc            /proc         proc      nosuid,noexec,nodev   0     0
sysfs           /sys          sysfs     nosuid,noexec,nodev   0     0
devpts          /dev/pts      devpts    gid=5,mode=620        0     0
tmpfs           /run          tmpfs     defaults              0     0
devtmpfs        /dev          devtmpfs  mode=0755,nosuid      0     0

EOF

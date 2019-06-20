#!/bin/bash
set -e
echo "Start.."

# 根据lfs-book8.4建好分区和环境,以及创建lfs用户,运行prepare.sh

# 注意分区的时候应该分出一个1M左右的分区,type使用BIOS boot, 如下:
# sda
#  |_sda1 -------- BIOS boot (1~2M)
#  |_sda2 -------- boot ext2
#  |_sda3 -------- root ext4
#  |_sda4 -------- home ext4
#  |_sda5 -------- swap swap

# prepare to build
sh /tools/run-prepare.sh

# execute rest as root
exec sudo -E -u root /bin/sh - <<EOF
#  change ownership
chown -R root:root $LFS/tools
# prevent "bad interpreter: Text file busy"
sync
# continue
sh /tools/run-build.sh
sh /tools/run-image.sh
EOF

# 使用这个命令创建,当prepare运行完毕,退出lfs用户登录,使用宿主机的root用户运行
# sudo chown -R root:root $LFS/tools
# sudo -E -u root /bin/sh -c "sh /tools/run-build.sh"
# sudo -E -u root /bin/sh -c "sh /tools/run-image.sh"

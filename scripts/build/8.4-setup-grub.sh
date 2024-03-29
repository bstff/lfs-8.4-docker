#!/bin/bash
set -e
echo "Using GRUB to setup the boot process.."

echo "NOTE: skipped. Check 8.4 chapter of LFS book for details"

#cd /tmp
#grub-mkrescue --output=grub-img.iso
#xorriso -as cdrecord -v dev=/dev/cdrw blank=as_needed grub-img.iso

# install GRUB
grub-install /dev/sda

# create grub config
cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2
set root=(hd0,2)  # /boot所在分区

menuentry "GNU/Linux, Linux 4.20.12-lfs-8.4" {
        linux   /boot/vmlinuz-4.20.12-lfs-8.4 root=/dev/sda2 ro
        # 如果/boot在单独的一个分区,应使用
        # linux   /vmlinuz-4.20.12-lfs-8.4 root=/dev/sda2 ro
        # 其中root=/dev/xxx 代表/根系统所在分区
}
EOF

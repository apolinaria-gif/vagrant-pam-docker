#!/bin/bash

# Если диски еще не размечены, создаем разделы и файловую систему прямо на лету
for disk in /dev/sdb /dev/sdc; do
    if [ -b "$disk" ]; then
        if ! blkid "${disk}1" >/dev/null 2>&1; then
            parted -s "$disk" mklabel gpt
            parted -s "$disk" mkpart primary ext4 0% 100%
            mkfs.ext4 -F "${disk}1"
        fi
        
        if [ "$disk" = "/dev/sdb" ]; then
            mount_point="/mnt/disk1"
        else
            mount_point="/mnt/disk2"
        fi
        
        mkdir -p "$mount_point"
        if ! mountpoint -q "$mount_point"; then
            mount "${disk}1" "$mount_point"
        fi
        
        uuid=$(blkid -s UUID -o value "${disk}1")
        if ! grep -q "$uuid" /etc/fstab; then
            echo "UUID=$uuid $mount_point ext4 defaults 0 2" >> /etc/fstab
        fi
    fi
done

echo "Настройка дисков успешно завершена!"
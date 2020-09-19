#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

# install nginx
yum update
yum install -y nginx

# make sure nginx is started
systemctl start nginx
systemctl enable nginx

# creating a partion and mounting the volume
partled -l
parted mklabel msdos
mkpart primary ext4 0 1G
quit

mkfs.ext4 /dev/xvdb1

mkdir -p /web
mount /dev/xvdb1 /web
echo "/dev/xvdb1    /web    ext4    defaults    1   1" >> /etc/fstab



#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

# install apache
yum update
yum install -y httpd

# make sure apache webserver is started and enabled
systemctl start httpd
systemctl enable httpd

# creating a partion and mounting the volume
partled -l
parted mklabel msdos
mkpart primary ext4 0 1G
quit

mkfs.ext4 /dev/xvdb1

mkdir -p /web
mount /dev/xvdb1 /web
echo "/dev/xvdb1    /web    ext4    defaults    1   1" >> /etc/fstab



#!/bin/bash
echo "Started nvmemount script" | sudo tee -a /var/log/diskmount.log
(echo g; echo n; echo ''; echo ''; echo ''; echo w) | sudo fdisk /dev/nvme0n1
while [[ ! -e /dev/nvme0n1p1 ]]; do sleep 5; done
sudo /sbin/mkfs.ext3 /dev/nvme0n1p1
sudo mkdir -p /var/lib/dcos
echo '/dev/nvme0n1p1 /var/lib/dcos ext3 defaults,_netdev,noatime 0 2' | sudo tee -a /etc/fstab
sudo mount -a
echo "Mounting '/var/lib/dcos' succeeded" | sudo tee -a /var/log/diskmount.log

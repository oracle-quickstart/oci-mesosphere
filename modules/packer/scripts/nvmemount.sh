#!/bin/bash
echo "Attaching NVMe" | sudo tee -a /var/log/diskmount.log
(echo g; echo n; echo ''; echo ''; echo ''; echo w) | sudo fdisk /dev/nvme0n1
while [[ ! -e /dev/nvme0n1p1 ]]; do sleep 5; done
echo "Format and mount disk" | sudo tee -a /var/log/diskmount.log
sudo /sbin/mkfs.ext3 /dev/nvme0n1p1
sudo mkdir -p /var/lib/dcos
echo '/dev/nvme0n1p1 /var/lib/dcos ext3 defaults,_netdev,noatime 0 2' | sudo tee -a /etc/fstab
sudo mount -a
echo "Mounted at '/var/lib/dcos' " | sudo tee -a /var/log/diskmount.log

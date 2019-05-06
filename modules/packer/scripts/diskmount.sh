#!/bin/bash
echo "Attaching disk" | sudo tee -a /var/log/diskmount.log
counter=0
while [ ! -e /dev/oracleoci/oraclevdb ]; do
    sleep 100
    counter=$((counter + 1))
    if [ $counter -ge 500 ]; then
      echo "Attaching '/dev/oracleoci/oraclevdb' failed" | sudo tee -a /var/log/diskmount.log
      exit
    fi
done
echo "Attached disk '/dev/oracleoci/oraclevdb' " | sudo tee -a /var/log/diskmount.log
(echo g; echo n; echo ''; echo ''; echo ''; echo w) | sudo fdisk /dev/oracleoci/oraclevdb
while [[ ! -e /dev/oracleoci/oraclevdb1 ]]; do sleep 5; done
sudo /sbin/mkfs.ext3 /dev/oracleoci/oraclevdb1
sudo mkdir -p /var/lib/dcos
echo '/dev/oracleoci/oraclevdb1 /var/lib/dcos ext3 defaults,_netdev,noatime 0 2' | sudo tee -a /etc/fstab
sudo mount -a
echo "Mounted '/dev/oracleoci/oraclevdb' at'/var/lib/dcos' " | sudo tee -a /var/log/diskmount.log

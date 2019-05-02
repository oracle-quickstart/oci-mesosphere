#!/bin/bash
counter=0
while [ ! -e /dev/oracleoci/oraclevdb ]; do
    sleep 100
    counter=$((counter + 1))
    if [ $counter -ge 50 ]; then
      echo "Device '/dev/oracleoci/oraclevdb' has not been attached"
      exit
    fi
done
echo "Attached device '/dev/oracleoci/oraclevdb'"
(echo g; echo n; echo ''; echo ''; echo ''; echo w) | sudo fdisk /dev/oracleoci/oraclevdb
while [[ ! -e /dev/oracleoci/oraclevdb1 ]]; do sleep 5; done
sudo mkfs.xfs /dev/oracleoci/oraclevdb1
sudo mkdir -p /var/lib/dcos
echo '/dev/oracleoci/oraclevdb1 /var/lib/dcos xfs defaults,_netdev,nofail 0 2' | sudo tee -a /etc/fstab
sudo mount -a

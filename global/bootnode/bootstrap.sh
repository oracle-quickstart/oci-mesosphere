
#!/bin/bash
sudo yum -y update
sudo /tmp/diskmount.sh
sudo rm -r /tmp/diskmount.sh
echo 'This is the mesos bootstrap node' | sudo tee /etc/motd

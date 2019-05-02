
#!/bin/bash
sudo yum -y update
sudo /tmp/diskmount.sh
sudo rm -r /tmp/diskmount.sh
echo 'This is the mesos bootnode' | sudo tee /etc/motd

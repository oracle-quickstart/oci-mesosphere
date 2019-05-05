#cloud-config
runcmd:
- touch /var/log/diskmount.log
- echo "Mesos Slave Node" >> /etc/motd
- mkdir /run/opc
- mv /tmp/diskmount.sh /run/opc/diskmount.sh
- chown root:root /run/opc/diskmount.sh
- chmod 755 /run/opc/diskmount.sh
- /run/opc/diskmount.sh
- mkdir /tmp/dcos && cd /tmp/dcos
- curl -O http://10.1.50.115:80/dcos_install.sh
- bash dcos_install.sh slave > /var/log/mesosinstall.log


output:
    init:
        output: "> /var/log/cloud-init.out"
        error: "> /var/log/cloud-init.err"
    config: "tee -a /var/log/cloud-config.log"
    final:
        - ">> /var/log/cloud-final.out"
        - "/var/log/cloud-final.err"

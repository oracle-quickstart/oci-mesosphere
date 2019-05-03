#cloud-config
runcmd:
- touch /var/log/diskmount.log
- echo "Mesos Bootnode" >> /etc/motd
- mkdir /run/opc
- mv /tmp/diskmount.sh /run/opc/diskmount.sh
- chown root:root /run/opc/diskmount.sh
- chmod 755 /run/opc/diskmount.sh
- /run/opc/diskmount.sh

output:
    init:
        output: "> /var/log/cloud-init.out"
        error: "> /var/log/cloud-init.err"
    config: "tee -a /var/log/cloud-config.log"
    final:
        - ">> /var/log/cloud-final.out"
        - "/var/log/cloud-final.err"

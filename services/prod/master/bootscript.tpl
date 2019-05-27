#cloud-config
runcmd:
- touch /var/log/diskmount.log
- echo "Mesos Master Node" >> /etc/motd
- mkdir /run/opc
- mv /tmp/nvmemount.sh /run/opc/nvmemount.sh
- chown root:root /run/opc/nvmemount.sh
- chmod 755 /run/opc/nvmemount.sh
- /run/opc/nvmemount.sh
- mkdir /tmp/dcos && cd /tmp/dcos
- curl -O http://mesosboot.mgtsubnet.mesosnet.oraclevcn.com:80/dcos_install.sh
- chmod 755 /tmp/dcos/dcos_install.sh
- bash /tmp/dcos/dcos_install.sh master > /var/log/mesosinstall.log 2> /var/log/mesosinstall.err

output:
    init:
        output: "> /var/log/cloud-init.out"
        error: "> /var/log/cloud-init.err"
    config: "tee -a /var/log/cloud-config.log"
    final:
        - ">> /var/log/cloud-final.out"
        - "/var/log/cloud-final.err"

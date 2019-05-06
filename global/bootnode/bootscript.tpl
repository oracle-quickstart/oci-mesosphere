#cloud-config
runcmd:
- echo "Mesos Bootnode" >> /etc/motd
- mkdir -p /home/opc/genconf
- mv /tmp/config.yaml /home/opc/genconf/config.yaml
- mv /tmp/license.txt /home/opc/genconf/license.txt
- mv /tmp/dcos_generate_config.ee.sh /home/opc/dcos_generate_config.ee.sh
- mv /tmp/dcos_generate_config.sh /home/opc/dcos_generate_config.sh
- chmod 755 /home/opc/dcos_generate_config.ee.sh
- mv /tmp/ip-detect /home/opc/genconf/ip-detect
- chmod 755 /home/opc/genconf/ip-detect
- /home/opc/genconf/ip-detect >> /home/opc/bootnode_ip.txt

output:
    init:
        output: "> /var/log/cloud-init.out"
        error: "> /var/log/cloud-init.err"
    config: "tee -a /var/log/cloud-config.log"
    final:
        - ">> /var/log/cloud-final.out"
        - "/var/log/cloud-final.err"

#cloud-config
runcmd:
- echo "Mesos Bootnode" >> /etc/motd
- mkdir -p ~/genconf
- mv /tmp/config.yaml ~/genconf/config.yaml
- mv /tmp/license.txt ~/genconf/license.txt
- mv /tmp/dcos_generate_config.ee.sh ~/genconf/dcos_generate_config.ee.sh
- chmod 755 ~/genconf/dcos_generate_config.ee.sh
- mv /tmp/ip-detect ~/genconf/ip-detect
- chmod 755 ~/genconf/ip-detect
- echo ~/genconf/ip-detect >> ~/genconf/bootnode_ip.txt

output:
    init:
        output: "> /var/log/cloud-init.out"
        error: "> /var/log/cloud-init.err"
    config: "tee -a /var/log/cloud-config.log"
    final:
        - ">> /var/log/cloud-final.out"
        - "/var/log/cloud-final.err"

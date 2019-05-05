#cloud-config
runcmd:
- echo "Squid Proxy Node" >> /etc/motd
- firewall-cmd --permanent --zone=public --add-forward-port=port=80:proto=tcp:toport=3128:toaddr=10.1.50.57
- sudo firewall-cmd --permanent --zone=public --add-port=3128/tcp
- sudo firewall-cmd --permanent --zone=public --add-masquerade
- sudo firewall-cmd --reload



output:
    init:
        output: "> /var/log/cloud-init.out"
        error: "> /var/log/cloud-init.err"
    config: "tee -a /var/log/cloud-config.log"
    final:
        - ">> /var/log/cloud-final.out"
        - "/var/log/cloud-final.err"

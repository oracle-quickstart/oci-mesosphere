#cloud-config
runcmd:
- echo "NGINX Proxy" >> /etc/motd
- mkdir -p /var/www/mesos.ocilabs.io/public_html
- touch nano /var/www/mesos.ocilabs.io/public_html/index.html
- echo "Hello World" | sudo tee -a /var/www/mesos.ocilabs.io/public_html/index.html
- chmod 755 /var/www/mesos.ocilabs.io/public_html/index.html
- mkdir /etc/nginx/sites-available
- mkdir /etc/nginx/sites-enabled
- mv /tmp/reverse-proxy.conf /etc/nginx/sites-available/reverse-proxy.conf
- mv /tmp/mesos.ocilabs.io.conf /etc/nginx/sites-available/mesos.ocilabs.io.conf
- mv /tmp/nginx.conf /etc/nginx/nginx.conf
- ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
- systemctl restart nginx

output:
    init:
        output: "> /var/log/cloud-init.out"
        error: "> /var/log/cloud-init.err"
    config: "tee -a /var/log/cloud-config.log"
    final:
        - ">> /var/log/cloud-final.out"
        - "/var/log/cloud-final.err"

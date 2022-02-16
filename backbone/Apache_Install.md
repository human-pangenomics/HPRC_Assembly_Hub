# Instructions For Setting Up Apache

## Install Apache
Following https://medium.com/@akshaypunekar/introduction-and-installation-of-apache-web-server-on-aws-ec2-instance-ad9027eab87f)
```
sudo apt update
sudo apt install apache2 -y

## Check status:
sudo systemctl status apache2
```

## Redirect to UCSC Genome Browser
```
sudo nano /etc/apache2/apache2.conf
## convert (under var/www/): AllowOverride None
## to: AllowOverride All
```
```
cd /var/www/html
sudo nano .htaccess
## insert
## Redirect /index.html http://genome.ucsc.edu/cgi-bin/hgGateway?genome=HG00621.1&hubUrl=http://hprc-browser.ucsc.edu/hub/hub.txt

## restart server for changes to take effect
sudo service apache2 restart
``` 

## requires AWS CLI & git

## ssh -i ~/.ssh/xxxxxxxxxxx.pem \
##    ubuntu@xxxxxxxxxxx.us-west-2.compute.amazonaws.com

############################################################################### 
##                             Download GitHub Repo                          ##
###############################################################################

cd ~
git clone https://github.com/juklucas/HPRC_Assembly_Hub.git

cd HPRC_Assembly_Hub

## set variable to hold assembly hub git
HUB_REPO=$(pwd)


############################################################################### 
##                               Random Setup                                ##
###############################################################################


sudo apt update && apt upgrade  -y

sudo timedatectl set-timezone 'America/Los_Angeles'

sudo hostnamectl set-hostname browser-instance

## install fail2ban
apt-get install fail2ban

sudo sed -i '1 a\
35.80.111.76 hprc-browser.ucsc.edu' /etc/hosts

############################################################################### 
##                              Install Apache                               ##
###############################################################################

sudo apt install apache2 -y

## create apache group
sudo groupadd apache

## Add the ubuntu user to the apache group
sudo usermod -a -G apache ubuntu

## Change the group ownership of the /var/www directory and its contents to the apache group
sudo chown -R ubuntu:apache /var/www

# Change the directory permissions of /var/www and its subdirectories to add group write 
## permissions and set the group ID on subdirectories created in the future
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;


############################################################################### 
##                      Forward Traffic To Preloaded Browser                 ##
###############################################################################

sudo nano /etc/apache2/apache2.conf
## convert (under var/www/): AllowOverride None
## to: AllowOverride All

## Put in redirect
sudo echo \
	"Redirect /index.html http://genome.ucsc.edu/cgi-bin/hgGateway?genome=HG00621.1&hubUrl=http://35.80.111.76/hub/hub.txt" \
	> /var/www/html/.htaccess

## reload for changes to take effect
sudo systemctl reload apache2

############################################################################### 
##                        Copy Over Marina's Current Hub                     ##
###############################################################################

cd /var/www/html/

sudo mkdir hub 
cd hub   


## Copy over Marina's hub files (~1 hour)
aws --no-sign-request s3 cp --recursive s3://marina-misc/HPRC/AssemblyHub/ .

## Copy updated groups file (we have added additional groups)
cp ${HUB_REPO}/backbone/groups.txt groups.txt

############################################################################### 
##                             Install Tools                                 ##
###############################################################################

cd /opt/

sudo wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedToBigBed
sudo chmod a+x bedToBigBed
echo 'export PATH="$PATH:/opt"' >> ~/.bashrc 

############################################################################### 
##                        		  DONE 				                         ##
###############################################################################
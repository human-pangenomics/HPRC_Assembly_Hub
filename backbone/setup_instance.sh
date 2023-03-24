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
echo 'export HUB_REPO=/home/ubuntu/HPRC_Assembly_Hub/' >> ~/.bashrc


############################################################################### 
##                               Random Setup                                ##
###############################################################################


sudo apt update && apt upgrade  -y

# sudo timedatectl set-timezone 'America/Los_Angeles'

# sudo hostnamectl set-hostname browser-instance

## install fail2ban
# apt-get install fail2ban

sudo sed -i '1 a\
52.32.252.169 hprc-browser.ucsc.edu' /etc/hosts

## Install the AWS CLI (no need to setup permissions, we are pulling files w/out egress fees)
## also install make
sudo apt install make python3-pip awscli -y
python3 -m pip install pipettor

############################################################################### 
##                              Install Apache                               ##
###############################################################################

# sudo apt install apache2 -y

## create apache group
sudo groupadd apache

## Add the ubuntu user to the apache group
sudo usermod -a -G apache ubuntu

## Change the group ownership of the hub directory and its contents to the apache group
sudo chown -R ubuntu:apache /mnt/disks/data/www

# Change the directory permissions of /var/www and its subdirectories to add group write 
## permissions and set the group ID on subdirectories created in the future
sudo chmod 2775 /mnt/disks/data/www
find /mnt/disks/data/www -type d -exec sudo chmod 2775 {} \;


############################################################################### 
##                      Forward Traffic To Preloaded Browser                 ##
###############################################################################

sudo nano /etc/apache2/apache2.conf
## convert (under var/www/): AllowOverride None
## to: AllowOverride All

## Put in redirect
sudo echo \
	"Redirect /index.html http://genome.ucsc.edu/cgi-bin/hgGateway?genome=HG00621.1&db=HG00621.1&hubUrl=http://35.80.111.76/hub/hub.txt" \
	> /mnt/disks/data/www/html/.htaccess

## reload for changes to take effect
sudo systemctl reload apache2

############################################################################### 
##                        Copy Over Marina's Current Hub                     ##
###############################################################################

cd /mnt/disks/data/www/html/


## Copy over Marina's hub files (~1 hour)
aws --no-sign-request s3 cp --recursive s3://marina-misc/HPRC/AssemblyHub/ .

## Copy updated groups file (we have added additional groups)
cp ${HUB_REPO}/backbone/groups.txt groups.txt

## Copy updated hub.txt file
cp ${HUB_REPO}/backbone/hub.txt hub.txt

############################################################################### 
##                                Setup BLAT Server                          ##
###############################################################################


sudo adduser blatuser
sudo usermod -a -G apache blatuser


sudo apt update
sudo apt install xinetd

sudo nano /etc/xinetd.d/blat-xinetd

service blat
{
          port            = 4040
          socket_type     = stream
          wait            = no
          user            = blatuser
          group           = apache
          server          = /opt/gfServer
          server_args     = -syslog -logFacility=local0 dynserver/scratch/hubs
          type            = UNLISTED
          log_on_success  += USERID PID HOST DURATION EXIT
          log_on_failure  += USERID HOST ATTEMPT
          log_type       = SYSLOG local0
          per_source      = 50
          disable         = no
}


sudo systemctl enable xinetd
sudo systemctl start xinetd


############################################################################### 
##                             Install Tools                                 ##
###############################################################################

cd /opt/

sudo wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedToBigBed
sudo wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/gff3ToGenePred
sudo wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/genePredToBigGenePred
sudo wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/faToTwoBit
sudo chmod a+x bedToBigBed gff3ToGenePred genePredToBigGenePred faToTwoBit

sudo wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/gfServer
sudo chmod a+x gfServer

sudo wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/isPcr
sudo chmod a+x isPcr

sudo wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/blat/blat
sudo chmod a+x blat


echo 'export PATH="$PATH:/opt"' >> ~/.bashrc 

############################################################################### 
##                        		  DONE 			             ##
###############################################################################

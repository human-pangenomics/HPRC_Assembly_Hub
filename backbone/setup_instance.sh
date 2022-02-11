## requires AWS CLI
## must have alias HUB_REPO set

############################################################################### 
##                        Copy Over Marina's Current Hub                     ##
###############################################################################

cd /var/www/html/

sudo mkdir hub 
sudo chown  ubuntu hub 
sudo chmod -R o+r hub 
cd hub   


## Copy over Marina's hub files
aws --no-sign-request s3 cp --recursive s3://marina-misc/HPRC/AssemblyHub/ .


## Copy updated groups file (we have added additional groups)
cp ${HUB_REPO}/backbone/groups.txt groups.txt


############################################################################### 
##                             Install Tools                                 ##
###############################################################################

cd /opt/

sudo wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedToBigBed
sudo chmod a+x bedToBigBed
export PATH=$PATH:/opt

############################################################################### 
##                        		  DONE 				                         ##
###############################################################################
# HPRC_Assembly_Hub

## Prerequisites

We are currently using an EC2 instance to serve the browser files:
- ubuntu 18.04
- t3.medium (may need to be adjusted later)
- dont assign public IP (will use elastic IP)
- storage = 800GB
- create new security group "hprc-assembly-hub"

Be sure to associate an elastic IP address to the instance as we use a DNS "A" record for hprc-browser.ucsc.edu pointing to the elastic IP.

## Prepare For Run
1. Install the AWS CLI:
```
sudo apt install awscli -y
```
There is no need to setup permissions, we are pulling files w/out egress fees

2. Get the files from this repo
```
cd ~
git clone https://github.com/juklucas/HPRC_Assembly_Hub.git
```
And set the alias HUB_REPO
```
echo 'export HUB_REPO=/home/ubuntu/HPRC_Assembly_Hub' >> ~/.bashrc 
source .bashrc
```

## Create The Hub

### Copy Over Marina's Hub
```
bash $HUB_REPO/backbone/setup_instance.sh
```
### Add Tracks
```

bash $HUB_REPO/dna_brnn/create_dna_brnn_track.sh
bash $HUB_REPO/flagger/create_flagger_track.sh
bash $HUB_REPO/sedef/create_sedef_track.sh
bash $HUB_REPO/trf/create_trf_track.sh
bash $HUB_REPO/repeat_masker/create_repeat_masker_track.sh
```

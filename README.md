# HPRC_Assembly_Hub

## Prerequisites

We are currently using an EC2 instance to serve the browser files:
- ubuntu 18.04
- t3.medium (may need to be adjusted later)
- dont assign public IP (will use elastic IP)
- storage = 800GB
- create new security group "hprc-assembly-hub"

Be sure to associate an elastic IP address to the instance as we use a DNS "A" record for hprc-browser.ucsc.edu pointing to the elastic IP.

## Preparation
1. Install the AWS CLI:
```
sudo apt install awscli -y
```
There is no need to setup permissions, we are pulling files w/out egress fees

## Create The Hub

Run shell commands in:
```
$HUB_REPO/backbone/setup_instance.sh
```
(Can't be executed as a script)

**These commands:**
* Download this repo
* Prepares instance (minimal server setup, install Apache, redirect traffic)
* Copy Over Marina's Hub
* Install bedToBigBed

### Add Tracks
```
bash $HUB_REPO/dna_brnn/create_dna_brnn_track.sh
bash $HUB_REPO/flagger/create_flagger_track.sh
bash $HUB_REPO/sedef/create_sedef_track.sh
bash $HUB_REPO/trf/create_trf_track.sh
bash $HUB_REPO/repeat_masker/create_repeat_masker_track.sh
bash $HUB_REPO/pggb_segdups/create_pggb_segdups_track.sh
```

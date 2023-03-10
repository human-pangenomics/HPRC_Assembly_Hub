# HPRC_Assembly_Hub

## Prerequisites

We are currently using an EC2 instance to serve the browser files:
- ubuntu 18.04
- t3.medium (may need to be adjusted later)
- dont assign public IP (will use elastic IP)
- storage = 800GB
- create new security group "hprc-assembly-hub"

Be sure to associate an elastic IP address to the instance as we use a DNS "A" record for hprc-browser.ucsc.edu pointing to the elastic IP.

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
bash $HUB_REPO/track_builds/dna_brnn/create_dna_brnn_track.sh
bash $HUB_REPO/track_builds/flagger/create_flagger_track.sh
bash $HUB_REPO/track_builds/sedef/create_sedef_track.sh
bash $HUB_REPO/track_builds/trf/create_trf_track.sh
bash $HUB_REPO/track_builds/repeat_masker/create_repeat_masker_track.sh
bash $HUB_REPO/track_builds/pggb_segdups/create_pggb_segdups_track.sh
bash $HUB_REPO/track_builds/alpha_sat/create_alpha_sat_track.sh
bash $HUB_REPO/track_builds/hsat2and3/create_hsat2and3_track.sh
```

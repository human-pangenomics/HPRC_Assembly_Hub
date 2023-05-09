#! /bin/bash

set -eou pipefail
## must have alias HUB_REPO set
## Get HUB_DIR
source ${HUB_REPO}/backbone/envs.txt

# TODO: merge with setup.sh after getting that up to date

mkdir -p $HUB_DIR/shared
find ${HUB_REPO}/track_builds -name "*.html" | xargs -I% cp % $HUB_DIR/shared

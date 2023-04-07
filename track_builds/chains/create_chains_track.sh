#! /bin/bash

set -eou pipefail
## must have alias HUB_REPO set
## Get HUB_DIR
source ${HUB_REPO}/backbone/envs.txt

############################################################################### 
##                             Info                                          ##
###############################################################################
# Creating the chains from the .hal files can be done using wdl/docker 
# inputs:
# s3://human-pangenomics/publications/PANGENOME_2022/hub/GRCh38-f1g-90-mc-aug11.hal
# or
# s3://human-pangenomics/publications/PANGENOME_2022/hub/CHM13-f1g-90-mc-aug11.hal

## Get data from s3 
#s3://human-pangenomics/submissions/A512ED34-9A91-4FC1-91A5-7AA162D7AFB2--Y1-BIGCHAINS/aggr_bigchains/GRCh38
# the bigbed files are already created; simply point to them (must use http link; see trackDb.txt file)

readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/assembly_list.txt

############################################################################### 
##                             Create chains track                           ##
###############################################################################

## Loop through assemblies and add asm-to-ref alignment
for ASSEMBLY in "${ASSEMBLIES[@]}" CHM13
do 
    sed "s/fillinsample/${ASSEMBLY}/" ${HUB_REPO}/track_builds/chains/chains_trackDb.txt |\
    sed "s/fillinsample/${ASSEMBLY}/" > ${HUB_DIR}/${ASSEMBLY}/chains_trackDb.txt


## Add import statement if it's not already there
if grep -q 'include chains_trackDb.txt' ${HUB_DIR}/${ASSEMBLY}/trackDb.txt; then
    echo found
else
    sed -i '1 i\include chains_trackDb.txt' ${HUB_DIR}/${ASSEMBLY}/trackDb.txt
fi

done


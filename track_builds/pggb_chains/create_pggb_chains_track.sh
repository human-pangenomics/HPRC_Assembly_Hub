#! /bin/bash

### WARNING: I don't know the central storage location of these so I moved them from
### another version MUST FIX

set -eou pipefail
## must have alias HUB_REPO set
## Get HUB_DIR
source ${HUB_REPO}/backbone/envs.txt

############################################################################### 
##                             Info                                          ##
###############################################################################

# not all assemblies have chains files
ASSEMBLIES=$(grep -v NA19240 ${HUB_REPO}/assembly_info/assembly_list.txt | grep -v HG00[25]\.)

############################################################################### 
##                             Create chains track                           ##
###############################################################################

## Loop through assemblies and add asm-to-ref alignment
for ASSEMBLY in $ASSEMBLIES CHM13
do 
    sed "s/fillinsample/${ASSEMBLY}/g" ${HUB_REPO}/track_builds/pggb_chains/pggb_chains_trackDb.txt |\
    sed "s/fillinsample/${ASSEMBLY}/g" > ${HUB_DIR}/${ASSEMBLY}/pggb_chains_trackDb.txt


## Add import statement if it's not already there
if grep -q 'include pggb_chains_trackDb.txt' ${HUB_DIR}/${ASSEMBLY}/trackDb.txt; then
    echo found
else
    sed -i '1 i\include pggb_chains_trackDb.txt' ${HUB_DIR}/${ASSEMBLY}/trackDb.txt
fi

done


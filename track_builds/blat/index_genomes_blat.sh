## requires AWS CLI, gfServer
## must have alias HUB_REPO set
## Get BLAT_DIR
source $HUB_REPO/backbone/envs.txt


############################################################################### 
##                             Create Indexes                                ##
###############################################################################


readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/assembly_list.txt
ASSEMBLIES+=("GRCh38")
ASSEMBLIES+=("CHM13")

for ASSEMBLY in "${ASSEMBLIES[@]}"
do 

    gfServer index \
        -stepSize=5 \
        ${BLAT_DIR}/${ASSEMBLY}/${ASSEMBLY}.untrans.gfidx \
        ${BLAT_DIR}/${ASSEMBLY}/${ASSEMBLY}.2bit

    gfServer index \
        -trans \
        ${BLAT_DIR}$/{ASSEMBLY}/${ASSEMBLY}.trans.gfidx \
        ${BLAT_DIR}$/{ASSEMBLY}/${ASSEMBLY}.2bit

done



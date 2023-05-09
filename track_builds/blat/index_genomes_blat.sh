## requires AWS CLI, gfServer
## must have alias HUB_REPO set
## Get HUB_DIR
source $HUB_REPO/backbone/envs.txt


############################################################################### 
##                             Create Indexes                                ##
###############################################################################


readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/assembly_list.txt
ASSEMBLIES+=("GRCh38")
ASSEMBLIES+=("CHM13")

for ASSEMBLY in "${ASSEMBLIES[@]}"
do 

    if [ ! -f "${HUB_DIR}/${ASSEMBLY}/${ASSEMBLY}.untrans.gfidx" ]; then
        gfServer index \
            -stepSize=5 \
            ${HUB_DIR}/${ASSEMBLY}/${ASSEMBLY}.untrans.gfidx \
            ${HUB_DIR}/${ASSEMBLY}/${ASSEMBLY}.2bit
    fi
    if [ ! -f "${HUB_DIR}/${ASSEMBLY}/${ASSEMBLY}.trans.gfidx" ]; then
        gfServer index \
            -trans \
            ${HUB_DIR}/${ASSEMBLY}/${ASSEMBLY}.trans.gfidx \
            ${HUB_DIR}/${ASSEMBLY}/${ASSEMBLY}.2bit
    fi

done



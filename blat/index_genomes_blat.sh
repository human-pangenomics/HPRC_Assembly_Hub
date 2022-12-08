## requires AWS CLI, gfServer
## must have alias HUB_REPO set

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
        /mnt/disks/data/www/html/${ASSEMBLY}/${ASSEMBLY}.untrans.gfidx \
        /mnt/disks/data/www/html/${ASSEMBLY}/${ASSEMBLY}.2bit

    gfServer index \
        -trans \
        /mnt/disks/data/www/html$/{ASSEMBLY}/${ASSEMBLY}.trans.gfidx \
        /mnt/disks/data/www/html$/{ASSEMBLY}/${ASSEMBLY}.2bit

done



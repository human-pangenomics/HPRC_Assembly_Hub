## requires AWS CLI, gfServer
## must have alias HUB_REPO set

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################


readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/assembly_list.txt
ASSEMBLIES+=("GRCh38")
ASSEMBLIES+=("CHM13")

for ASSEMBLY in "${ASSEMBLIES[@]}"
do 

    gfServer index \
        -stepSize=5 \
        /var/www/html/hub/${ASSEMBLY}/${ASSEMBLY}.untrans.gfidx \
        /var/www/html/hub/${ASSEMBLY}/${ASSEMBLY}.2bit

    gfServer index \
        -trans \
        /var/www/html/hub/${ASSEMBLY}/${ASSEMBLY}.trans.gfidx \
        /var/www/html/hub/${ASSEMBLY}/${ASSEMBLY}.2bit

done



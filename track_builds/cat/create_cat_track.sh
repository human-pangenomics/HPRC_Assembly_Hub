## requires AWS CLI
set -eou pipefail
## must have alias HUB_REPO set
## Get HUB_DIR
source ${HUB_REPO}/backbone/envs.txt

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################

## TODO: move these files to our pangenome s3 location
## Get data from S3 submission

# the bigbed files are already created, however not all assemblies have the files
#aws --no-sign-request s3 cp \
#    --recursive \
#    s3://marina-misc/HPRC/AssemblyHub/ \
#    ${HUB_DIR}/ \
#    --exclude "*" \
#    --include "*consensus.cmg*gencode38.bb"

readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/assembly_list.txt

for ASSEMBLY in "${ASSEMBLIES[@]}" 'CHM13'; do 
    #  HG002, HG005, and NA19240 have no consensus files, so skip these
    if [ -f "${HUB_DIR}/$ASSEMBLY/consensus.cmg-chm13.gencode38.bb" ]; then
        ## copy over cat trackDbs and add to main trackDb.txt file
        for tfile in consensus.cmg-chm13.gencode38_trackDb.txt \
            consensus.cmg-hg38.gencode38_trackDb.txt; do
                cp ${HUB_REPO}/track_builds/cat/$tfile ${HUB_DIR}/$ASSEMBLY/$tfile

                ## Add import statement if it's not already there
                if grep -q "include $tfile" ${HUB_DIR}/$ASSEMBLY/trackDb.txt; then
                    echo found
                else
                    awk -i inplace -v x="include $tfile" 'BEGINFILE{print x}{print}' ${HUB_DIR}/$ASSEMBLY/trackDb.txt
                fi
        done
    fi
done


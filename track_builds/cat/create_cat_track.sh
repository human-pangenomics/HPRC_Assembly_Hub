## requires AWS CLI
set -eou pipefail
## must have alias HUB_REPO set
## Get HUB_DIR
source ${HUB_REPO}/backbone/envs.txt

## work in a temporary directory
curdir=$(pwd)
workdir=$(mktemp -d --suffix=_cat_track)
cd $workdir

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################

## Get data from S3 submission

# the bigbed files are already created, however not all assemblies have the files
aws --no-sign-request s3 cp \
    --recursive \
    s3://human-pangenomics/submissions/6F88082C-E520-4E4D-9134-0001B08DC83E--Y1_CAT_chain_bigbed \
    .

readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/assembly_list.txt

for ASSEMBLY in "${ASSEMBLIES[@]}" 'CHM13'; do 
    for GVERSION in 'chm13' 'hg38'; do
        ##  HG002, HG005, and NA19240 have no consensus files; only create tracks when files exist
        if [ -f "${HUB_DIR}/$ASSEMBLY/consensus.cmg-$GVERSION.gencode38.bb" ]; then
    
            if [ ! -f ${HUB_DIR}/${ASSEMBLY}/consensus.cmg-$GVERSION.gencode38.ix ]; then
                ## index
                bigBedToBed ${HUB_DIR}/$ASSEMBLY/consensus.cmg-$GVERSION.gencode38.bb stdout | cut -f4,13,21,22 > $ASSEMBLY.$GVERSION.tsv
                ixIxx $ASSEMBLY.$GVERSION.tsv ${HUB_DIR}/${ASSEMBLY}/consensus.cmg-$GVERSION.gencode38.ix ${HUB_DIR}/${ASSEMBLY}/consensus.cmg-$GVERSION.gencode38.ixx
            fi

            ## copy over cat trackDb and add to main trackDb.txt file
            cp ${HUB_REPO}/track_builds/cat/consensus.cmg-$GVERSION.gencode38_trackDb.txt ${HUB_DIR}/$ASSEMBLY/consensus.cmg-$GVERSION.gencode38_trackDb.txt
    
            ## Add import statement if it's not already there
            if grep -q "include consensus.cmg-$GVERSION.gencode38_trackDb.txt" ${HUB_DIR}/$ASSEMBLY/trackDb.txt; then
                echo $ASSEMBLY found
            else
                awk -i inplace -v x="include consensus.cmg-$GVERSION.gencode38_trackDb.txt" 'BEGINFILE{print x}{print}' ${HUB_DIR}/$ASSEMBLY/trackDb.txt
            fi
        fi
    done
done

cd $curdir
rm -rf $workdir

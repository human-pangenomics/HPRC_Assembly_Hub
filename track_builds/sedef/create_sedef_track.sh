## requires AWS CLI
set -eou pipefail
## must have alias HUB_REPO set
## Get HUB_DIR
source ${HUB_REPO}/backbone/envs.txt

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################

## work in a temporary directory
curdir=$(pwd)
workdir=$(mktemp -d --suffix=_segdup_tmp)
cd $workdir



readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/assembly_list.txt


for ASSEMBLY in "${ASSEMBLIES[@]}"
do 
    echo $ASSEMBLY 
    
    ## extract sample name and haplotype
    SAMPLE=`echo "$ASSEMBLY" | cut -d'.' -f1`
    HAPLOTYPE=`echo "$ASSEMBLY" | cut -d'.' -f2`

    if [[ $HAPLOTYPE == 1 ]]; then
        HAP_STR=paternal
    else 
        HAP_STR=maternal
    fi

    if [ ! -f "${HUB_DIR}/${ASSEMBLY}/sedef.bb" ]; then
        if [ ! -f "${SAMPLE}/${SAMPLE}.${HAP_STR}.sedef.bedpe" ]; then
            ## Get all data from S3 submission (this creates bed files for all assemblies in the workdir)
            aws --no-sign-request s3 cp \
                --recursive \
                s3://human-pangenomics/submissions/403CA459-7947-4D49-A417-943DFA81A5CD--SEDEF/ \
                .

        fi
        ## Print select columns from first hit. Truncate contig name.
        awk -v 'FS=\t' -v 'OFS=\t' '{print $1,$2,$3,$7,$8,$9}' ${SAMPLE}/${SAMPLE}.${HAP_STR}.sedef.bedpe \
            | sed 's/^.*#\(J.*\)/\1/' \
            > ${SAMPLE}/${SAMPLE}.${HAP_STR}_1.bed 
    
        ## Print select columns from second hit. Truncate contig name.
        awk -v 'FS=\t' -v 'OFS=\t' '{print $4,$5,$6,$10}' ${SAMPLE}/${SAMPLE}.${HAP_STR}.sedef.bedpe \
            | sed 's/^.*#\(J.*\)/\1/' \
            > ${SAMPLE}/${SAMPLE}.${HAP_STR}_2.bed 
    
        ## Combine into one bed file
        paste ${SAMPLE}/${SAMPLE}.${HAP_STR}_1.bed ${SAMPLE}/${SAMPLE}.${HAP_STR}_2.bed > ${SAMPLE}/${SAMPLE}.${HAP_STR}_sedef_tmp.bed
    
        ## Convber to bigbed
        bedToBigBed \
            -type=bed4+6 \
            -tab \
            -as=${HUB_REPO}/track_builds/sedef/sedef.as \
            -sizesIs2Bit \
            ${SAMPLE}/${SAMPLE}.${HAP_STR}_sedef_tmp.bed \
            ${HUB_DIR}/$ASSEMBLY/${ASSEMBLY}.2bit \
            ${HUB_DIR}/$ASSEMBLY/sedef.bb
    fi 

    ## copy over sedef trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/track_builds/sedef/sedef_trackDb.txt ${HUB_DIR}/$ASSEMBLY/sedef_trackDb.txt 

    ## Add import statement if it's not already there
    if grep -q 'include sedef_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include sedef_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt
    fi

done

cd $curdir
rm -rf $workdir


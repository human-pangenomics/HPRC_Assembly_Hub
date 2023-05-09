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
workdir=$(mktemp -d --suffix=_hsat2and3_track)
cd $workdir


readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/assembly_list.txt


for ASSEMBLY in "${ASSEMBLIES[@]}"
do 
    ## extract sample name and haplotype
    SAMPLE=`echo "$ASSEMBLY" | cut -d'.' -f1`
    HAPLOTYPE=`echo "$ASSEMBLY" | cut -d'.' -f2`

    if [[ $HAPLOTYPE == 1 ]]; then
        HAP_STR=paternal
    else 
        HAP_STR=maternal
    fi

    if [ ! -f "${HUB_DIR}/${ASSEMBLY}/hsat2and3.bb" ]; then
        if [ ! -f "${SAMPLE}.${HAP_STR}.f1_assembly_v2_genbank.HSat2and3_Regions.bed" ]; then
            ## Get all data from S3 submission (this creates bed files for all assemblies in the workdir)
            aws --no-sign-request s3 cp \
                --recursive \
                s3://human-pangenomics/submissions/1A6CA334-DAF0-4186-AB3E-12442503F2BE--HSAT_2_3/ \
                .
        fi
        ## Strip off sample name and haplotype int (to match chrom.sizes file)
        sed 's/^.*#\(J.*\)/\1/' \
            ${SAMPLE}.${HAP_STR}.f1_assembly_v2_genbank.HSat2and3_Regions.bed \
            > ${SAMPLE}.${HAPLOTYPE}.hsat2and3.stripped.bed
    
        bedToBigBed \
            -extraIndex=name \
            -type=bed9 \
            -tab \
            -as=${HUB_REPO}/track_builds/hsat2and3/hsat2and3.as \
            -sizesIs2Bit \
            ${SAMPLE}.${HAPLOTYPE}.hsat2and3.stripped.bed \
            ${HUB_DIR}/$ASSEMBLY/$ASSEMBLY.2bit \
            ${HUB_DIR}/$ASSEMBLY/hsat2and3.bb
    fi    

    ## copy over hsat2and3 trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/track_builds/hsat2and3/hsat2and3_trackDb.txt ${HUB_DIR}/$ASSEMBLY/hsat2and3_trackDb.txt 

    ## Add import statement if it's not already there
    if grep -q 'include hsat2and3_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include hsat2and3_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt
    fi

done

cd $curdir
rm -rf $workdir

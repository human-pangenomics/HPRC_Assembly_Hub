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
workdir=$(mktemp -d --suffix=_trf_tracks)
cd $workdir



readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/assembly_list.txt


for ASSEMBLY in "${ASSEMBLIES[@]}"
do 
    echo $ASSEMBLY 
    
    ## extract sample name and haplotype
    SAMPLE=`echo "$ASSEMBLY" | cut -d'.' -f1`
    HAPLOTYPE=`echo "$ASSEMBLY" | cut -d'.' -f2`

    if [[ $HAPLOTYPE == 1 ]]; then
        HAP_STR=pat
    else 
        HAP_STR=mat
    fi

    if [ ! -f "${HUB_DIR}/${ASSEMBLY}/trf.bb" ]; then
        if [ ! -f "${SAMPLE}/${SAMPLE}.${HAP_STR}.trf.bed.gz" ]; then
            ## Get all data from S3 submission (this creates bed files for all assemblies in the workdir)
            aws --no-sign-request s3 cp \
                --recursive \
                s3://human-pangenomics/submissions/1FE2CB96-1B4D-4204-BE4E-08DB00746F68--YEAR_1_TRF \
                .
        fi
        zcat ${SAMPLE}/${SAMPLE}.${HAP_STR}.trf.bed.gz \
            | sed 's/^.*#\(J.*\)/\1/' \
            > ${SAMPLE}/${SAMPLE}.${HAPLOTYPE}.trf.bed
    
    
        ## Convert to bigbed
        bedToBigBed \
            -type=bed3+13 \
            -tab \
            -as=${HUB_REPO}/track_builds/trf/trf.as \
	    -sizesIs2Bit \
            ${SAMPLE}/${SAMPLE}.${HAPLOTYPE}.trf.bed \
            ${HUB_DIR}/$ASSEMBLY/$ASSEMBLY.2bit \ 
            ${HUB_DIR}/$ASSEMBLY/trf.bb
    fi


    ## copy over trf trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/track_builds/trf/trf_trackDb.txt ${HUB_DIR}/$ASSEMBLY/trf_trackDb.txt 

    ## Add import statement if it's not already there
    if grep -q 'include trf_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include trf_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt
    fi

done

cd $curdir
rm -rf $workdir

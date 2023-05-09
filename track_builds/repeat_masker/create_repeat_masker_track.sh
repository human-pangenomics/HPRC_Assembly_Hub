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
workdir=$(mktemp -d --suffix=_repeatmasker_track)
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

    if [ ! -f "${HUB_DIR}/${ASSEMBLY}/repeat_masker.bb" ]; then
        if [ ! -f "${SAMPLE}/assemblies/year1_f1_assembly_v2_genbank/repeat_masker/${SAMPLE}.${HAP_STR}.f1_assembly_v2_genbank_rm.bed" ]; then
            ## Get all data from S3 submission (this creates bed files for all assemblies in the workdir)
            aws --no-sign-request s3 cp \
                --recursive \
                s3://human-pangenomics/submissions/6C63D998-712A-480D-8BEC-99DD8DBE16C5--RM_BEDS/ \
                .
        fi

        ## Strip off sample name and haplotype int (to match chrom.sizes file)
	## also remove MT, which are present in some but not all 2bits
        sed 's/^.*#\(J.*\)/\1/' \
            ${SAMPLE}/assemblies/year1_f1_assembly_v2_genbank/repeat_masker/${SAMPLE}.${HAP_STR}.f1_assembly_v2_genbank_rm.bed | \
            grep -vP '#MT\t' > ${SAMPLE}/${SAMPLE}.${HAPLOTYPE}.rm.bed
    
        ## I think the type should actually be bed6+4, but I get an error saying: 
        ## Error line 35 of HG00438.1.rm.bed: score (1209) must be between 0 and 1000
        bedToBigBed \
            -extraIndex=name \
            -type=bed4+6 \
            -tab \
            -as=${HUB_REPO}/track_builds/repeat_masker/repeat_masker.as \
            -sizesIs2Bit \
            ${SAMPLE}/${SAMPLE}.${HAPLOTYPE}.rm.bed \
            ${HUB_DIR}/$ASSEMBLY/$ASSEMBLY.2bit \
            ${HUB_DIR}/$ASSEMBLY/repeat_masker.bb
    fi


    ## copy over repeat masker trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/track_builds/repeat_masker/repeat_masker_trackDb.txt ${HUB_DIR}/$ASSEMBLY/repeat_masker_trackDb.txt 

    ## Add import statement if it's not already there
    if grep -q 'include repeat_masker_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include repeat_masker_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt
    fi

done

cd $curdir
rm -rf $workdir

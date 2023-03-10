## requires AWS CLI
## must have alias HUB_REPO set

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################

## Get data from S3 submission
cd ~

mkdir pggb_segdups_tmp
cd pggb_segdups_tmp

aws --no-sign-request s3 cp \
    s3://human-pangenomics/pangenomes/scratch/2021_11_16_pggb_wgg.88/untangle/pggb_freeze1_untangle.vs.chm13.segdup_calls.bed.gz \
    .


readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/pangenome_assembly_list.txt


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

    ## Bed all pangnome haplotypes. We must split the haplotypes for the browser
    grep "^${SAMPLE}#${HAPLOTYPE}#" pggb_freeze1_untangle.vs.chm13.segdup_calls.bed.gz > ${SAMPLE}.${HAPLOTYPE}.pggb_segdups.bed

    ## Strip off sample name and haplotype int (to match chrom.sizes file)
    sed 's/^.*#\(J.*\)/\1/' \
        ${SAMPLE}.${HAPLOTYPE}.pggb_segdups.bed \
        > ${SAMPLE}.${HAPLOTYPE}.pggb_segdups.stripped.bed

    bedToBigBed \
        -type=bed3+6 \
        -tab \
        ${SAMPLE}.${HAPLOTYPE}.pggb_segdups.stripped.bed \
        -as=${HUB_REPO}/track_builds/pggb_segdups/pggb_segdups.as \
        /var/www/html/hub/$ASSEMBLY/chrom.sizes \
        /var/www/html/hub/$ASSEMBLY/pggb_segdups.bb


    ## copy over pggb_segdups trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/track_builds/pggb_segdups/pggb_segdups_trackDb.txt /var/www/html/hub/$ASSEMBLY/pggb_segdups_trackDb.txt 

    ## Add import statement if it's not already there
    if grep -q 'include pggb_segdups_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include pggb_segdups_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt
    fi

done

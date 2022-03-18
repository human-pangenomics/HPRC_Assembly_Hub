## requires AWS CLI
## must have alias HUB_REPO set

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################

## Get data from S3 submission
cd ~

mkdir flagger_tmp
cd flagger_tmp

aws --no-sign-request s3 cp \
    --recursive \
    s3://human-pangenomics/submissions/e9ad8022-1b30-11ec-ab04-0a13c5208311--COVERAGE_ANALYSIS_Y1_GENBANK/FLAGGER/JAN_09_2022/FINAL_HIFI_BASED/FLAGGER_HIFI_ASM_SIMPLIFIED_BEDS/UNRELIABLE_ONLY_NO_MT/ \
    .


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

    ## Bed has both haplotypes. We must split the haplotypes for the browser
    grep "^${SAMPLE}#${HAPLOTYPE}#" ${SAMPLE}.hifi.flagger_final.bed > ${SAMPLE}.${HAPLOTYPE}.hifi.flagger_final.bed

    ## Strip off sample name and haplotype int (to match chrom.sizes file)
    sed 's/^.*#\(J.*\)/\1/' \
        ${SAMPLE}.${HAPLOTYPE}.hifi.flagger_final.bed \
        > ${SAMPLE}.${HAPLOTYPE}.hifi.flagger_final.stripped.bed

    bedToBigBed \
        -extraIndex=name \
        -type=bed9 \
        -tab \
        ${SAMPLE}.${HAPLOTYPE}.hifi.flagger_final.stripped.bed \
        -as=${HUB_REPO}/flagger/flagger.as \
        /var/www/html/hub/$ASSEMBLY/chrom.sizes \
        /var/www/html/hub/$ASSEMBLY/flagger.bb


    ## copy over flagger trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/flagger/flagger_trackDb.txt /var/www/html/hub/$ASSEMBLY/flagger_trackDb.txt 

    ## Add import statement if it's not already there
    if grep -q 'include flagger_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include flagger_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt
    fi

done


cd ~
rm flagger_tmp


## requires AWS CLI
## must have alias HUB_REPO set

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################

## Get data from S3 submission
cd ~

mkdir trf_tmp
cd trf_tmp

aws --no-sign-request s3 cp \
    --recursive \
    s3://human-pangenomics/submissions/1FE2CB96-1B4D-4204-BE4E-08DB00746F68--YEAR_1_TRF \
    .


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

    zcat ${SAMPLE}/${SAMPLE}.${HAP_STR}.trf.bed.gz \
        | sed 's/^.*#\(J.*\)/\1/' \
        | awk -v 'FS=\t' -v 'OFS=\t' 'NF{NF-=1};1' \
        > ${SAMPLE}/${SAMPLE}.${HAPLOTYPE}.trf.bed


    ## Convber to bigbed
    bedToBigBed \
        -type=bed3+13 \
        -tab \
        ${SAMPLE}/${SAMPLE}.${HAPLOTYPE}.trf.bed \
        -as=${HUB_REPO}/trf/trf.as \
        /var/www/html/hub/$ASSEMBLY/chrom.sizes \
        /var/www/html/hub/$ASSEMBLY/trf.bb


    ## copy over trf trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/trf/trf_trackDb.txt /var/www/html/hub/$ASSEMBLY/trf_trackDb.txt 

    ## Add import statement if it's not already there
    if grep -q 'include trf_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include trf_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt
    fi

done


cd ~
rm trf_tmp


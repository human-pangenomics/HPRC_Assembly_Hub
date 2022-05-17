## requires AWS CLI
## must have alias HUB_REPO set

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################

## Get data from S3 submission
cd ~

mkdir alpha_sat_tmp
cd alpha_sat_tmp

aws --no-sign-request s3 cp \
    --recursive \
    s3://human-pangenomics/submissions/08934468-0AE3-42B6-814A-C5422311A53D--HUMAS_HMMER/ \
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

    ## Strip off sample name and haplotype int (to match chrom.sizes file)
    sed 's/^.*#\(J.*\)/\1/' \
        ${SAMPLE}/AS-HOR+SF-vs-${SAMPLE}-${HAP_STR}.bed \
        | awk -v 'FS=\t' -v 'OFS=\t' '{ $5=int($5); print }' \
        > ${SAMPLE}.${HAPLOTYPE}.alpha_sat.stripped.bed

    bedToBigBed \
        -extraIndex=name \
        -type=bed9 \
        -tab \
        ${SAMPLE}.${HAPLOTYPE}.alpha_sat.stripped.bed \
        -as=${HUB_REPO}/alpha_sat/alpha_sat.as \
        /var/www/html/hub/$ASSEMBLY/chrom.sizes \
        /var/www/html/hub/$ASSEMBLY/alpha_sat.bb


    ## copy over alpha_sat trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/alpha_sat/alpha_sat_trackDb.txt /var/www/html/hub/$ASSEMBLY/alpha_sat_trackDb.txt 

    ## Add import statement if it's not already there
    if grep -q 'include alpha_sat_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include alpha_sat_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt
    fi

done


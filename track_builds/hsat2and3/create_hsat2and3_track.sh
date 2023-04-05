## requires AWS CLI
## must have alias HUB_REPO set

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################

## Get data from S3 submission
cd ~

mkdir hsat2and3_tmp
cd hsat2and3_tmp

aws --no-sign-request s3 cp \
    --recursive \
    s3://human-pangenomics/submissions/1A6CA334-DAF0-4186-AB3E-12442503F2BE--HSAT_2_3/ \
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
        ${SAMPLE}.${HAP_STR}.f1_assembly_v2_genbank.HSat2and3_Regions.bed \
        > ${SAMPLE}.${HAPLOTYPE}.hsat2and3.stripped.bed

    bedToBigBed \
        -extraIndex=name \
        -type=bed9 \
        -tab \
        ${SAMPLE}.${HAPLOTYPE}.hsat2and3.stripped.bed \
        -as=${HUB_REPO}/track_builds/hsat2and3/hsat2and3.as \
        /var/www/html/hub/$ASSEMBLY/chrom.sizes \
        /var/www/html/hub/$ASSEMBLY/hsat2and3.bb


    ## copy over hsat2and3 trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/track_builds/hsat2and3/hsat2and3_trackDb.txt /var/www/html/hub/$ASSEMBLY/hsat2and3_trackDb.txt 
    cp ${HUB_REPO}/track_builds/hsat2and3/hsat2and3.html /var/www/html/hub/$ASSEMBLY/hsat2and3.html

    ## Add import statement if it's not already there
    if grep -q 'include hsat2and3_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include hsat2and3_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt
    fi

done


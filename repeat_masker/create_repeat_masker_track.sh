## requires AWS CLI
## must have alias HUB_REPO set

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################

## Get data from S3 submission
cd ~

mkdir repeat_masker_tmp
cd repeat_masker_tmp

aws --no-sign-request s3 cp \
    --recursive \
    s3://human-pangenomics/submissions/6C63D998-712A-480D-8BEC-99DD8DBE16C5--RM_BEDS/ \
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
        ${SAMPLE}/assemblies/year1_f1_assembly_v2_genbank/repeat_masker/${SAMPLE}.${HAP_STR}.f1_assembly_v2_genbank_rm.bed \
        > ${SAMPLE}/${SAMPLE}.${HAPLOTYPE}.rm.bed

    ## I think the type should actually be bed6+4, but I get an error saying: 
    ## Error line 35 of HG00438.1.rm.bed: score (1209) must be between 0 and 1000
    bedToBigBed \
        -extraIndex=name \
        -type=bed4+6 \
        -tab \
        ${SAMPLE}/${SAMPLE}.${HAPLOTYPE}.rm.bed \
        -as=${HUB_REPO}/repeat_masker/repeat_masker.as \
        /var/www/html/hub/$ASSEMBLY/chrom.sizes \
        /var/www/html/hub/$ASSEMBLY/repeat_masker.bb


    ## copy over repeat masker trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/repeat_masker/repeat_masker_trackDb.txt /var/www/html/hub/$ASSEMBLY/repeat_masker_trackDb.txt 

    ## Add import statement if it's not already there
    if grep -q 'include repeat_masker_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include repeat_masker_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt
    fi

done


cd ~
sudo rm repeat_masker_tmp


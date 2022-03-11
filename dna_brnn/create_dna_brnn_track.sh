## requires AWS CLI
## must have alias HUB_REPO set

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################

## Get data from S3 submission
cd ~

mkdir dna_brnn_tmp
cd dna_brnn_tmp

aws --no-sign-request s3 cp \
    --recursive \
    s3://human-pangenomics/submissions/2CB43373-C91E-41B1-AD2B-57E8D870A5E0--DNA_BRNN/ \
    .


readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/pangenome_assembly_list.txt



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

    ## Convber to bigbed
    bedToBigBed \
        -type=bed4 \
        -tab \
        ${SAMPLE}.${HAP_STR}.f1_assembly_v2_genbank.dna_brnn.bed \
        -as=${HUB_REPO}/dna_brnn/dna_brnn.as \
        /var/www/html/hub/$ASSEMBLY/chrom.sizes \
        /var/www/html/hub/$ASSEMBLY/dna_brnn.bb


    ## copy over sedef trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/dna_brnn/dna_brnn_trackDb.txt /var/www/html/hub/$ASSEMBLY/dna_brnn_trackDb.txt 

    ## Add import statement if it's not already there
    if grep -q 'include dna_brnn_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include dna_brnn_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt
    fi

done


cd ~
rm dna_brnn_tmp


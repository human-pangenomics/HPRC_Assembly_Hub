## must have alias HUB_REPO set
## Note that there is some annotation version variety
## Also note that we're getting info from parsing a html file which is... not ideal.

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################

# function to create bigbed from gff3
make_bb(){
    echo ${ASSEMBLY}
    gunzip ${ASSEMBLY}.gff3.gz
    if [ "${ASSEMBLY}" == "CHM13" ]; then
        ${HUB_REPO}/software/bin/ensemblGff3ToBigEnsembl \
	    --ucsc-names \
    	    ${ASSEMBLY}.gff3 \
    	    ${ASSEMBLY}.ensembl.gp
    else
        ${HUB_REPO}/software/bin/ensemblGff3ToBigEnsembl \
    	    ${ASSEMBLY}.gff3 \
    	    ${ASSEMBLY}.ensembl.gp
    fi
    bedToBigBed \
        -type=bed12+12 \
        -tab \
        -as=${HUB_REPO}/track_builds/ensembl_genes/ensembl_genes.as \
        ${ASSEMBLY}.ensembl.gp \
        /var/www/html/hub/${ASSEMBLY}/chrom.sizes \
        /var/www/html/hub/${ASSEMBLY}/ensembl_genes.bb
#    rm ${ASSEMBLY}.ensembl.gp ${ASSEMBLY}.gff3
}
# function to add trackdb with correct annotation version
add_trackdb(){
    sed "s/version/version $version/" ${HUB_REPO}/track_builds/ensembl_genes/ensembl_genes_trackDb.txt > /var/www/html/hub/$ASSEMBLY/ensembl_genes_trackDb.txt 
    ## Add import statement if it's not already there
    if grep -q 'include ensembl_genes_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include ensembl_genes_trackDb.txt' /var/www/html/hub/$ASSEMBLY/trackDb.txt
    fi
}

cd ~

mkdir -p ensembl_tmp
cd ensembl_tmp
## Get data from ensembl.org
#wget -O index.html https://projects.ensembl.org/hprc/index.html
grep '\.gff' index.html | sed 's/.*https/https/' | cut -f1 -d'"' > gff.files
# mapping of genbank IDs to assemblies
#wget https://raw.githubusercontent.com/human-pangenomics/HPP_Year1_Assemblies/main/genbank_changes/y1_genbank_assembly_accession_ids.txt

tail -n +2 y1_genbank_assembly_accession_ids.txt | while read SAMPLE mat pat; do
    ASSEMBLY=${SAMPLE}.2
    if [ ! -f "/var/www/html/hub/${ASSEMBLY}/ensembl.bb" ]; then
        wget -O ${ASSEMBLY}.gff3.gz $(grep $mat gff.files)
        make_bb
        version=$(grep $mat gff.files | sed 's/.*geneset.//' | cut -f1 -d'/') # 2022-07 or 2022-08
        add_trackdb
        ASSEMBLY=${SAMPLE}.1
        wget -O ${ASSEMBLY}.gff3.gz $(grep $pat gff.files)
        make_bb
        version=$(grep $pat gff.files | sed 's/.*geneset.//' | cut -f1 -d'/') 
    fi
done
exit


# CHM13 is different in that it uses 'chr' in the chromosome ID. It also only has one haplotype.
ASSEMBLY='CHM13'
wget -O $ASSEMBLY.gff3.gz https://ftp.ensembl.org/pub/rapid-release/species/Homo_sapiens/GCA_009914755.4/ensembl/geneset/2022_07/Homo_sapiens-GCA_009914755.4-2022_07-genes.gff3.gz
make_bb
version='2022_07'
add_trackdb

exit


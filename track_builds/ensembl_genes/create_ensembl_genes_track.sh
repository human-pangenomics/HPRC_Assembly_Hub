## must have alias HUB_REPO set
set -eou pipefail
## Get HUB_DIR
source ${HUB_REPO}/backbone/envs.txt
## Note that there is some annotation version variety
## Also note that we're getting info from parsing a html file which is... not ideal.

############################################################################### 
##                             Functions                                     ##
###############################################################################


# function to create bigbed from gff3
make_bb(){
    echo ${ASSEMBLY}
    if [ "${ASSEMBLY}" == "CHM13" ]; then
        ${HUB_REPO}/software/bin/ensemblGff3ToBigEnsembl \
	    --ucsc-names \
    	    ${ASSEMBLY}.gff3.gz \
    	    ${ASSEMBLY}.ensembl.gp
    else
        ${HUB_REPO}/software/bin/ensemblGff3ToBigEnsembl \
    	    ${ASSEMBLY}.gff3.gz \
    	    ${ASSEMBLY}.ensembl.gp
    fi
    # index for creatng lowercase gene names
    cut -f4,13,18,19 ${ASSEMBLY}.ensembl.gp > ${ASSEMBLY}.id.tsv
    ixIxx ${ASSEMBLY}.id.tsv ${HUB_DIR}/${ASSEMBLY}/ensembl_genes.ix ${HUB_DIR}/${ASSEMBLY}/ensembl_genes.ixx
    bedToBigBed \
        -type=bed12+12 \
        -tab \
        -extraIndex=name,name2,geneName,geneName2 \
        -as=${HUB_REPO}/track_builds/ensembl_genes/ensembl_genes.as \
        -sizesIs2Bit \
        ${ASSEMBLY}.ensembl.gp \
        ${HUB_DIR}/${ASSEMBLY}/${ASSEMBLY}.2bit \
        ${HUB_DIR}/${ASSEMBLY}/ensembl_genes.bb
}
# function to add trackdb with correct annotation version
add_trackdb(){
    sed "s/version/version $version/" ${HUB_REPO}/track_builds/ensembl_genes/ensembl_genes_trackDb.txt > ${HUB_DIR}/$ASSEMBLY/ensembl_genes_trackDb.txt 
    ## Add import statement if it's not already there
    if grep -q 'include ensembl_genes_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt; then
        echo $ASSEMBLY found
    else
        sed -i '1 i\include ensembl_genes_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt
    fi
}

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################


## work in a temporary directory
curdir=$(pwd)
workdir=$(mktemp -d --suffix=_ensembl_track)
cd $workdir

## Get data from ensembl.org
if [ ! -f "gff.files" ]; then
    wget -O index.html https://projects.ensembl.org/hprc/index.html
    grep '\.gff' index.html | sed 's/.*https/https/' | cut -f1 -d'"' > gff.files
fi
# mapping of genbank IDs to assemblies
if [ ! -f "y1_genbank_assembly_accession_ids.txt" ]; then
    wget https://raw.githubusercontent.com/human-pangenomics/HPP_Year1_Assemblies/main/genbank_changes/y1_genbank_assembly_accession_ids.txt
    # add newline
    echo >> y1_genbank_assembly_accession_ids.txt
fi

# loop through pairs of maternal, paternal IDs per sample
tail -n +2 y1_genbank_assembly_accession_ids.txt | while read SAMPLE mat pat; do
    ASSEMBLY=${SAMPLE}.2
    if [ ! -f "${HUB_DIR}/${ASSEMBLY}/ensembl_genes.bb" ]; then
        wget -O ${ASSEMBLY}.gff3.gz $(grep $mat gff.files)
        make_bb
    fi
    version=$(grep $mat gff.files | sed 's/.*geneset.//' | cut -f1 -d'/') # 2022-07 or 2022-08
    add_trackdb
    ASSEMBLY=${SAMPLE}.1
    if [ ! -f "${HUB_DIR}/${ASSEMBLY}/ensembl_genes.bb" ]; then
        wget -O ${ASSEMBLY}.gff3.gz $(grep $pat gff.files)
        make_bb
    fi
    version=$(grep $pat gff.files | sed 's/.*geneset.//' | cut -f1 -d'/') 
    add_trackdb
done

# CHM13 is different in that it uses 'chr' in the chromosome ID. It also only has one haplotype.
ASSEMBLY='CHM13'
echo $ASSEMBLY
if [ ! -f "${HUB_DIR}/${ASSEMBLY}/ensembl_genes.bb" ]; then
    wget -O $ASSEMBLY.gff3.gz https://ftp.ensembl.org/pub/rapid-release/species/Homo_sapiens/GCA_009914755.4/ensembl/geneset/2022_07/Homo_sapiens-GCA_009914755.4-2022_07-genes.gff3.gz
    make_bb
fi
version='2022_07'
add_trackdb

cd $curdir
rm -rf $workdir

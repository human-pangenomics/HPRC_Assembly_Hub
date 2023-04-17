set -eou pipefail
## must have alias HUB_REPO set
## Get HUB_DIR
source ${HUB_REPO}/backbone/envs.txt


############################################################################### 
##                             Create 2bit                                   ##
###############################################################################

## work in a temporary directory
curdir=$(pwd)
workdir=$(mktemp -d --suffix=_2bit)
cd $workdir

## Genbank sometimes adds a version number, changing this:
##(...)/all/GCA/018/469/665/GCA_018469665.1_HG01123.pri.mat.f1_v2/GCA_018469665.1_HG01123.pri.mat.f1_v2_genomic.fna.gz
## into this (please notice both version numbers change):
##(...)/all/GCA/018/469/665/GCA_018469665.1_HG01123.pri.mat.f1_v2.1/GCA_018469665.1_HG01123.pri.mat.f1_v2.1_genomic.fna.gz
## we try to fix it while running, updating the input file. To do that we need to work from a copy.
cp ${HUB_REPO}/track_builds/2bit/y1_genbank_assembly_ftp_paths.txt .
cat y1_genbank_assembly_ftp_paths.txt | while read ASSEMBLY FPATH; do
    echo $ASSEMBLY
    if [ ! -f "${HUB_DIR}/${ASSEMBLY}/${ASSEMBLY}.2bit" ]; then
	# try/except
	if ! wget -O ${ASSEMBLY}.fa.gz $FPATH; then
            newpath=$(echo $FPATH | sed "s/f1_v2/f1_v2.1/g")
	    wget -O ${ASSEMBLY}.fa.gz $newpath
	    echo "Fixing: in y1_genbank_assembly_ftp_paths.txt $ASSEMBLY path is now $newpath"
	    # can't sed because path contains slashes
	    grep -vP "$ASSEMBLY\t" ${HUB_REPO}/track_builds/2bit/y1_genbank_assembly_ftp_paths.txt > keepme
	    echo -e "$ASSEMBLY\t$newpath" >> keepme
	    mv keepme ${HUB_REPO}/track_builds/2bit/y1_genbank_assembly_ftp_paths.txt

	    #sed -i "s/$ASSEMBLY	.*/$ASSEMBLY	$newpath/" ${HUB_REPO}/track_builds/2bit/y1_genbank_assembly_ftp_paths.txt 
	fi
        faToTwoBit -noMask ${ASSEMBLY}.fa.gz ${HUB_DIR}/${ASSEMBLY}/${ASSEMBLY}.2bit
        rm ${ASSEMBLY}.fa.gz 
    fi
done

# pull hg38 and CHM13 from browser
wget -O ${HUB_DIR}/GRCh38/GRCh38.2bit https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.2bit
wget -O ${HUB_DIR}/CHM13/CHM13.2bit https://hgdownload.soe.ucsc.edu/goldenPath/hs1/bigZips/hs1.2bit
# This should be the 2bit of
#ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/914/755/GCA_009914755.4_T2T-CHM13v2.0/GCA_009914755.4_T2T-CHM13v2.0_genomic.fna.gz" >> y1_genbank_assembly_ftp_paths.txt

cd $curdir
rm -rf $workdir

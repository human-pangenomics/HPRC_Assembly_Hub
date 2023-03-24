
# These paths are input for 2bit and are now stored in 
# https://raw.githubusercontent.com/human-pangenomics/HPP_Year1_Assemblies/main/genbank_changes/y1_genbank_assembly_ftp_paths.txt
############################################################################### 
##                            Create ftp paths                               ##
###############################################################################

wget https://raw.githubusercontent.com/human-pangenomics/HPP_Year1_Assemblies/main/genbank_changes/y1_genbank_assembly_accession_ids.txt
echo >> y1_genbank_assembly_accession_ids.txt
tail -n +2 y1_genbank_assembly_accession_ids.txt | while read SAMPLE mat pat; do
    ASSEMBLY=${SAMPLE}.2
    split=$(perl -E '($v1) = @ARGV; $v1 =~ m/GCA_(...)(...)(...)../; print "$1/$2/$3"' $mat)
    matname="${mat}_${SAMPLE}.pri.mat.f1_v2"
    fpath="ftp.ncbi.nlm.nih.gov/genomes/all/GCA/$split/$matname/${matname}_genomic.fna.gz"
    echo "$ASSEMBLY	$fpath"
    ASSEMBLY=${SAMPLE}.1
    split=$(perl -E '($v1) = @ARGV; $v1 =~ m/GCA_(...)(...)(...)../; print "$1/$2/$3"' $pat)
    patname="${pat}_${SAMPLE}.alt.pat.f1_v2"
    fpath="ftp.ncbi.nlm.nih.gov/genomes/all/GCA/$split/$patname/${patname}_genomic.fna.gz"
    echo "$ASSEMBLY	$fpath"
done | tee y1_genbank_assembly_ftp_paths.txt
# I checked that these files exist using curl --list-only $fpath

# had to manually update HG01123 and HG01358 to change v2 to v2.1 in the fpaths



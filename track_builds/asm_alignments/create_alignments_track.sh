## requires AWS CLI, gfServer
set -eou pipefail
## must have alias HUB_REPO set
## Get HUB_DIR
source ${HUB_REPO}/backbone/envs.txt

readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/assembly_list.txt

############################################################################### 
##                             Create GRCh38 Aln                             ##
###############################################################################

cd ${HUB_DIR}/GRCh38

## Copy in base of alignments trackDB file
cp ${HUB_REPO}/track_builds/asm_alignments/GRCh38_alignments.txt .


## Loop through assemblies and add asm-to-ref alignment
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

    echo "
	    track ${SAMPLE}_${HAP_STR}_Aln
	    shortLabel ${SAMPLE} ${HAP_STR} on GRCh38
	    longLabel ${SAMPLE} ${HAP_STR} Aligned To GRCh38	    
	    visibility hide
	    parent asmToGRCh38 off
	    priority 3
	    bigDataUrl https://s3-us-west-2.amazonaws.com/human-pangenomics/submissions/b56f2db9-e93f-4e1a-99fe-cb66962dd564--Yale_HPP_Year1_Alignments/${SAMPLE}/assembly-to-reference/${SAMPLE}.${HAP_STR}.GRCh38_no_alt.bam
	    type bam
            html GRCh38_alignments.html
	    group compGeno" >> GRCh38_alignments.txt

done


## Add import statement if it's not already there
if grep -q 'include GRCh38_alignments.txt' trackDb.txt; then
    echo found
else
    sed -i '1 i\include GRCh38_alignments.txt' trackDb.txt
fi

############################################################################### 
##                             Create CHM13 Aln                              ##
###############################################################################

cd ${HUB_DIR}/CHM13

## Copy in base of alignments trackDB file
cp ${HUB_REPO}/track_builds/asm_alignments/CHM13_alignments.txt .

## Loop through assemblies and add asm-to-ref alignment
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

    echo "
	    track ${SAMPLE}_${HAP_STR}_Aln
	    shortLabel ${SAMPLE} ${HAP_STR} on CHM13
	    longLabel ${SAMPLE} ${HAP_STR} Aligned To CHM13
	    visibility hide
	    parent asmToCHM13 off
	    priority 3
	    bigDataUrl https://s3-us-west-2.amazonaws.com/human-pangenomics/submissions/b56f2db9-e93f-4e1a-99fe-cb66962dd564--Yale_HPP_Year1_Alignments/${SAMPLE}/assembly-to-reference/${SAMPLE}.${HAP_STR}.CHM13Y_EBV.bam
	    type bam
            html CHM13_alignments.html
	    group compGeno" >> CHM13_alignments.txt

done


## Add import statement if it's not already there
if grep -q 'include CHM13_alignments.txt' trackDb.txt; then
    echo found
else
    sed -i '1 i\include CHM13_alignments.txt' trackDb.txt
fi


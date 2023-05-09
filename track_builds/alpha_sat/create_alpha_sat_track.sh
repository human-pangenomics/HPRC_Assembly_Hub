## requires AWS CLI
set -eou pipefail
## requires HUB_REPO to be set
## Get HUB_DIR
source ${HUB_REPO}/backbone/envs.txt

############################################################################### 
##                             Create BigBeds                                ##
###############################################################################


## work in a temporary directory
curdir=$(pwd)
workdir=$(mktemp -d --suffix=_alpha_sat_track)
cd $workdir


readarray -t ASSEMBLIES <${HUB_REPO}/assembly_info/assembly_list.txt


for ASSEMBLY in "${ASSEMBLIES[@]}"
do 
    echo ${ASSEMBLY}
    ## extract sample name and haplotype
    SAMPLE=`echo "$ASSEMBLY" | cut -d'.' -f1`
    HAPLOTYPE=`echo "$ASSEMBLY" | cut -d'.' -f2`

    if [[ $HAPLOTYPE == 1 ]]; then
        HAP_STR=paternal
    else 
        HAP_STR=maternal
    fi

    if [ ! -f "${HUB_DIR}/${ASSEMBLY}/alpha_sat.bb" ]; then
        if [ ! -f "${SAMPLE}/AS-HOR+SF-vs-${SAMPLE}-${HAP_STR}.bed" ]; then
	   ## Get all data from S3 submission (this creates bed files for all assemblies in the workdir)	
            aws --no-sign-request s3 cp \
                --recursive \
                s3://human-pangenomics/submissions/08934468-0AE3-42B6-814A-C5422311A53D--HUMAS_HMMER/ \
                .
	fi
	## Strip off sample name and haplotype int (to match 2bit file)
        sed 's/^.*#\(J.*\)/\1/' \
            ${SAMPLE}/AS-HOR+SF-vs-${SAMPLE}-${HAP_STR}.bed \
            | awk -v 'FS=\t' -v 'OFS=\t' '{ $5=int($5); print }' \
            > ${SAMPLE}.${HAPLOTYPE}.alpha_sat.stripped.bed
    
        bedToBigBed \
            -extraIndex=name \
            -type=bed9 \
            -tab \
            -as=${HUB_REPO}/track_builds/alpha_sat/alpha_sat.as \
            -sizesIs2Bit \
            ${SAMPLE}.${HAPLOTYPE}.alpha_sat.stripped.bed \
            ${HUB_DIR}/${ASSEMBLY}/${ASSEMBLY}.2bit \
            ${HUB_DIR}/$ASSEMBLY/alpha_sat.bb
    fi

    ## copy over alpha_sat trackDb and add to main trackDb.txt file
    cp ${HUB_REPO}/track_builds/alpha_sat/alpha_sat_trackDb.txt ${HUB_DIR}/$ASSEMBLY/alpha_sat_trackDb.txt 

    ## Add import statement if it's not already there
    if grep -q 'include alpha_sat_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include alpha_sat_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt
    fi

done

cd $curdir
rm -rf $workdir

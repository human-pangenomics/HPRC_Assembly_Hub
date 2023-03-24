## requires AWS CLI 
## must have alias HUB_REPO set


############################################################################### 
##                             Create 2bit                                   ##
###############################################################################

# 
cd ~

mkdir -p s3_2bit_tmp /var/www/html/tmphub
cd s3_2bit_tmp
#wget https://raw.githubusercontent.com/human-pangenomics/HPP_Year1_Assemblies/main/assembly_index/Year1_assemblies_v2_genbank.index

tail -n +2 Year1_assemblies_v2_genbank.index | while read SAMPLE PPATH MPATH sum1 sum2; do
    ASSEMBLY=${SAMPLE}.1
    mkdir -p /var/www/html/tmphub/${ASSEMBLY}
    if [ ! -f "/var/www/html/tmphub/${ASSEMBLY}/${ASSEMBLY}.2bit" ]; then
        aws --no-sign-request s3 cp $PPATH .
        fname=$(basename $PPATH)
        faToTwoBit -noMask $fname /var/www/html/tmphub/${ASSEMBLY}/${ASSEMBLY}.2bit
        rm $fname
    fi
    ASSEMBLY=${SAMPLE}.2
    mkdir -p /var/www/html/tmphub/${ASSEMBLY}
    if [ ! -f "/var/www/html/tmphub/${ASSEMBLY}/${ASSEMBLY}.2bit" ]; then
        aws --no-sign-request s3 cp $MPATH .
        fname=$(basename $MPATH)
        faToTwoBit -noMask $fname /var/www/html/tmphub/${ASSEMBLY}/${ASSEMBLY}.2bit
        rm $fname
    fi
done




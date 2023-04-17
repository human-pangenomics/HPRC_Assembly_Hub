#! /bin/bash

# this is a VERY RUSHED piece of code just to get the snake chain stuff copied from the old version to the new.
# must deal with this properly later.

## requires AWS CLI
set -eou pipefail
## must have alias HUB_REPO set
## Get HUB_DIR
source ${HUB_REPO}/backbone/envs.txt

grep -n "track hubCentralCHM13" $HUB_DIR/oldhub/*/trackDb.txt | sed 's/:/ /g' > first
grep -n "track chainCentral" $HUB_DIR/oldhub/*/trackDb.txt > last

while read inf line1 a b; do
    line2=$(grep $inf last | cut -f2 -d':')
    let line2=$line2-1
    ASSEMBLY=$(echo $inf | sed 's/.*oldhub.//' | sed 's/.trackDb.txt//')
    echo "$ASSEMBLY $line1 $line2 $inf"
    sed -n "${line1},${line2}p" $inf | \
        sed 's/group alignments/group compGeno/' > $HUB_DIR/$ASSEMBLY/hubCentral_trackDb.txt
    ## Add import statement if it's not already there
    if grep -q 'include hubCentral_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt; then
        echo found
    else
        sed -i '1 i\include hubCentral_trackDb.txt' ${HUB_DIR}/$ASSEMBLY/trackDb.txt
    fi
done < first
rm first last


#!/usr/bin/env bash
for i in *all.zip;
do
    unzip $i export_deliverable.txt;
    rm $i;
    j=`echo $i | tr '[:lower:]' '[:upper:]'| sed 's/ADDRESSES-ALL.ZIP/addresses-letter.txt/g'`;
    mv export_deliverable.txt $j;
    ~/Workspace/ops/scripts/cedar.sh rrd $j;
    rm $j;
done
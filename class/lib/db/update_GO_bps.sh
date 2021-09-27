#!/bin/bash
organism=$1;
DIR=$2;

bpath="$DIR/class/lib/db/$organism";
mkdir -p $bpath
# rm $DIR/class/lib/db/gene_info_limit.gz;

echo "Downloading GO database...."
wget -P  $bpath/ http://purl.obolibrary.org/obo/go.obo --quiet;


cat $bpath/go.obo | grep "^id\:" | sed 's/id: //' >  $bpath/GO_id.txt;
cat $bpath/go.obo | grep "^name\:" | sed 's/name: //' >  $bpath/GO_desc.txt;
cat $bpath/go.obo | grep "^namespace\:" | sed 's/namespace: //' >  $bpath/GO_process.txt;

paste $bpath/GO_id.txt $bpath/GO_desc.txt $bpath/GO_process.txt | awk -F '\t' '{print $1"\t"$3"\t"$2;}' | grep "^GO:" > $bpath/GOWithDescProcess.txt;


org_taxid=`cat bp_gaf_data/pseudomallei_quickGO.gaf | grep -v "\!" | cut -f13 | head -n1 | sed 's/taxon\://'`;
cat bp_gaf_data/pseudomallei_quickGO.gaf | grep -v "\!" | awk 'BEGIN{FS="\t"}{if($12~"protein" || $12~"gene") print $3"\t"$5"\t"$9;}' | awk '!x[$0]++'>  $bpath/all_go.tmp;
cat $bpath/all_go.tmp | awk '{print $2"\t"$1}' >  $bpath/temp1.txt;

awk 'BEGIN{FS="\t"}{ if( !seen[$1]++ ) order[++oidx] = $1; stuff[$1] = stuff[$1] $2 "," } END { for( i = 1; i <= oidx; i++ ) print order[i]"\t"stuff[order[i]] }'  $bpath/temp1.txt >  $bpath/gene_association.grouped.txt;

cat $bpath/gene_association.grouped.txt | cut -f1 > $bpath/temp2.txt;

perl $DIR/class/scripts/common.pl $bpath/GOWithDescProcess.txt  $bpath/temp2.txt $DIR > $bpath/gene_association.grouped.annotation;



sort -k1 $bpath/gene_association.grouped.annotation > $bpath/gene_association.grouped.annotation.tmp1
sort -k1 $bpath/gene_association.grouped.txt | grep "^GO:" > $bpath/gene_association.grouped.txt.tmp1





awk -F"\t" 'NR==FNR {vals[$1] = $2"\t"$3; next} !($1 in vals) {vals[$1] = "0 0 0"} {$(NF+1) = vals[$1]; print}' $bpath/gene_association.grouped.annotation.tmp1 $bpath/gene_association.grouped.txt.tmp1 | sed 's/ /\t/' | sed 's/ /\t/' | awk -F"\t" '{print $1"~"$4"\t"$3"\t"$2;}' > $bpath/gene_association.grouped.annotated.txt;






cat $bpath/gene_association.grouped.annotated.txt | awk 'BEGIN{FS="\t"}{if($2~"molecular_function") print $1"\t"$3;}' >  $bpath/GO_MF_sym.txt;
cat $bpath/gene_association.grouped.annotated.txt | awk 'BEGIN{FS="\t"}{if($2~"cellular_component") print $1"\t"$3;}' >  $bpath/GO_CC_sym.txt;
cat $bpath/gene_association.grouped.annotated.txt | awk 'BEGIN{FS="\t"}{if($2~"biological_process") print $1"\t"$3;}' >  $bpath/GO_BP_sym.txt;
cat $bpath/gene_association.grouped.annotated.txt | awk 'BEGIN{FS="\t"}{print $1"\t"$3;}'>  $bpath/GO_all_sym.txt;

rm $bpath/all_go.tmp $bpath/gene_association.${organism}  $bpath/gene_association.grouped.annotated.txt  $bpath/gene_association.grouped.annotation  $bpath/gene_association.grouped.txt $bpath/GO_desc.txt  $bpath/GO_id.txt  $bpath/GO_process.txt $bpath/GOWithDescProcess.txt $bpath/gene_association.grouped.annotation.tmp1 $bpath/gene_association.grouped.txt.tmp1 $bpath/temp1.txt $bpath/temp2.txt $bpath/go.obo

echo "Database retreived..You are now ready to use geneSCF with organism $organism from --database GO";
DT=`/bin/date`;
echo "Done....$DT";


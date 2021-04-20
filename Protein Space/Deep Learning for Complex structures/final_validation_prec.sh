sed 's/.txt//' TABLE_RESNR > 1 | sed 's/out_//' 1 > 2
awk '{print $1 "\t\t" $9}' 2 > 3
sed 's/.pdb//' True_positive_FP_pairs_validation.txt > 4
awk '{print $1}' 4 > 5
paste  3 5 |column -t > 6
awk '{if ($1 = $3) print $0}' 6 | column -t | sort -nk 2 > 7
awk '{if ($2 >= 9 && $2 <= 12) print $0}' 7 >  optimzed_leads.txt 
#removing raw files
rm -rf 1 2 3 4 5 6 7



awk -F"," '{print $1, $2, $675}' RF_predicted_independent_test.csv > 1.csv
sed 's/"/ /g' 1.csv > 2.csv
awk  '{if ($2==1 && $3 == 1) print $0}' 2.csv | column -t > Identified_hits_from_independent_set.txt

# removing unwanted files
rm -rf  1.csv 2.csv 

awk -F"," '{print $1, $2, $675}' predicted_internal_test.csv > predicted_internal_test_1.csv
sed 's/"/ /g' predicted_internal_test_1.csv > predicted_internal_test_2.csv
awk  '{if ($2==1 && $3 == 1) print $0}' predicted_internal_test_2.csv | column -t > Identified_hits_for_internal_training.txt

# removing unwanted files
rm predicted_internal_test_1.csv predicted_internal_test_2.csv 

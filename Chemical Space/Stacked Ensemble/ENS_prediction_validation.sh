awk -F, '{print $1, "\t" $2}' validation_set_refined_according_to_model.csv > 1
awk -F, '{print $1}' ENS_predicted_indepenednt_test.csv > 2 
paste 1 2 > 1_2 | sed 's/\t/ /g' 1_2 | sed 's/"//g' 1_2 > 3 
awk '{if ($2==1 && $3 == 1) print $0}' 3 > Identified_hits_for_independent_set.txt

#removing free files
rm -rf 1 2 3 1_2

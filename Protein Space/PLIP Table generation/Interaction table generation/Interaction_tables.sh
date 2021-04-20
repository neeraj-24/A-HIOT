#!/bin/bash

#step1
for i in out_complex_*;
	do
	       	echo $i; 
	done |
	 	sed 's/_/ /g' | sort -nk 4 | sed 's/ /_/g' > list_out_complex && cp list_out_complex list_out_complex_output 
       		sed -i 's/.*/> &_OUT/g' list_out_complex_output

sed "s/.*/sed '1,13d' & \| sed 's\/\[\+\=\|\]\/\/g' \| sed 's\/-\/\/g' \| awk '\{print \$1\}' \| sed 's\/RESNR\/\/g' \| sed '\/^$\/d' \| awk -v patt=\"\\\*\" -v prev=1 '\$0 ~ patt \{print NR - prev; prev = NR\} END \{print NR + 1 - prev\}' \| sed 1d \| sed 's\/\$\/ 1\/g' \| awk '\{a=\$1-\$2;print \$0,a;\}' \| awk '\{print \$3\}' \| awk 'ORS=\" \"' /g" list_out_complex >script1

paste script1 list_out_complex_output > SCRIPT1
sh SCRIPT1

for i in  *_OUT; do echo $i; done  > All_output_file_list
for i in *.txt; do echo $i; done > All_input_file_list

sed "s/.*/awk \'NF\' & >> RESULT /g" All_output_file_list | sed '1s/>>/>/g' > Result_script
sh Result_script
paste All_input_file_list RESULT > RESULT_OUTPUT_WITH_FILE

#step2

awk '{print $1}' RESULT_OUTPUT_WITH_FILE | sed 's/$/_NAMES/' > ALL_out_NAMES_file_list
awk '{print $1}' RESULT_OUTPUT_WITH_FILE | sed "s/.*/grep \"\\\*\\\**\" & \| sed 's\/ \/_\/g' \| sed 's\/\\*\\*\/\/g' \| awk \'ORS\=\" \"\'  >    /g" > script_nam && paste script_nam ALL_out_NAMES_file_list >script1
sh script1
       	awk 'NR' *_NAMES > RESULT_NAME_OUTPUT_list

paste All_input_file_list RESULT_NAME_OUTPUT_list > RESULT_OUTPUT_WITH_NAME

#step3

for i in {2..6};
do
        echo "awk '{print \$1,$"$i"}' RESULT_OUTPUT_WITH_FILE > ";
done >loop1 &&
        for i in "line_one_no" "line_two_no" "line_three_no" "line_four_no" "line_five_no";
        do
                echo $i; done > loop2 &&
                        for i in {2..6};
                        do

                                echo "&& awk '{print $"$i"}' RESULT_OUTPUT_WITH_NAME > ";

                        done > loop3 &&

                                for i in "line_one_name" "line_two_name" "line_three_name" "line_four_name" "line_five_name";

                                do

                                        echo $i;

                                done > loop4 && paste loop1 loop2 loop3 loop4 | sed 's/$/ \&\& paste /g' > loop5  && paste loop5 loop2 loop4 > loop6 &&

                                        for i in {1..5};

                                        do

                                                echo \> $i;

                                        done > loop7 && paste loop6 loop7 | sed 's/\t/ /g' > loop1_loop7
					sh loop1_loop7



#step4

for interactions in "Halogen_Bonds" "Hydrophobic_Interactions" "Hydrogen_Bonds" "Metal_Complexes" "pi-Stacking" "pi-Cation_Interactions" "Salt_Bridges";

do
        echo $interactions;

done | sed "s/.*/grep \"&\" 1 2 3 4 5 \| sed 's\/:\/ \/g' \| awk '\{print \$2,\$3\}' > /g" > loop8 &&

        for i in "LIST_Halogen_Bonds" "LIST_Hydrophobic_Interactions" "LIST_Hydrogen_Bonds" "LIST_Metal_Complexes" "LIST_pi-Stacking" "LIST_pi-Cation_Interactions" "LIST_Salt_Bridges";

	do
                echo $i;

	done > loop9 && paste loop8 loop9 >loop8_loop9 
	sh loop8_loop9

#step5

sed "s/.*/awk \'\{print \$1\}\' & > /g" loop9 > loop10 && 

	for i in "Halogen_Bonds_files" "Hydrophobic_Interactions_files" "Hydrogen_Bonds_files" "Metal_Complexes_files" "pi-Stacking_files" "pi-Cation_Interactions_files" "Salt_Bridges_files"; 

	do 

		echo $i; 

	done > interaction_files_output && paste loop10 interaction_files_output > loop11 && sed "s/.*/\&\& awk \'FNR==NR \{a\[\$0\]\+\+; next\} \!a\[\$0\]\' & All_input_file_list \| sed \'s\/$\/ 0\/g\' \> /g"  interaction_files_output > loop12 && paste loop11 loop12 > loop13 && 

		for i in "NO_Halogen_Bonds_files" "NO_Hydrophobic_Interactions_files" "NO_Hydrogen_Bonds_files" "NO_Metal_Complexes_files" "NO_pi-Stacking_files" "NO_pi-Cation_Interactions_files" "NO_Salt_Bridges_files"; 

		do 

			echo $i; 

		done > loop14 && paste loop13 loop14 > loop15  
		sed 's/^/\&\& awk "NR" /g' loop9 > loop16 
	       	sed "s/$/ \| sed 's\/_\/  \/g' \| sort -nk 4 \| sed 's\/  \/_\/g'/g" loop14 > loop17 && paste loop15 loop16 loop17 | sed 's/\t/ /g' > loop10_loop17
		

			for i in "RESULT_Halogen_Bonds" "RESULT_Hydrophobic_Interactions" "RESULT_Hydrogen_Bonds" "RESULT_Metal_Complexes" "RESULT_pi-Stacking" "RESULT_pi-Cation_Interactions" "RESULT_Salt_Bridges"; 

			do 

				echo \> $i; 

			done > RESULT_list && paste loop10_loop17 RESULT_list > FINAL_SCRIPT 
				
sh FINAL_SCRIPT

#if there is no interaction in all files(blank file ZERO)
ls -lrth RESULT_Halogen_Bonds RESULT_Hydrogen_Bonds RESULT_Hydrophobic_Interactions RESULT_Metal_Complexes RESULT_pi-Cation_Interactions RESULT_pi-Stacking RESULT_Salt_Bridges | awk '{if  ($5==0) print $9}' > zero_interactions_file

cp list_out_complex ZERO
sed 's/$/ 0/g' ZERO > ZERO_INTERACTIONS

sed 's/^/cp ZERO_INTERACTIONS /g' zero_interactions_file |sh








#step6

paste RESULT_Halogen_Bonds RESULT_Hydrogen_Bonds RESULT_Hydrophobic_Interactions RESULT_Metal_Complexes RESULT_pi-Cation_Interactions RESULT_pi-Stacking RESULT_Salt_Bridges | awk '{print $1,$2,$4,$6,$8,$10,$12,$14}' |sed  "1 iFile_name Halogen_Bonds Hydrogen_Bonds Hydrophobic_Interactions Metal_Complexes pi-Cation_Interactions pi-Stacking Salt_Bridges"| column -t > TABLE


#interaction counting

awk '{$1=""}1' TABLE | sed '1d' | awk '{for(i=1; i<=NF; i++) t+=$i; print t; t=0}' | sed "1 iTOTAL_Interactions" > TOTAL_Interactions_count
paste TABLE TOTAL_Interactions_count | column -t > TABLE_RESNR

rm *_OUT *_NAMES l* L* R* All_* N* *files 1 2 3 4 5 

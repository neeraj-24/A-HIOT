#! /bin/bash
for a in out_*; do
	d=`$a`
	cd $a
	echo copying complex files
	cp *.txt /home/user/DNN_RF/pipeline_validation/dud_e/Biological_space/validation_set/validation_pdbqt/validation_vs_output/complex_files_commom/PLIP_interactions_for_validation_complexs/PLIP_report_files_at_common_folder/
	cd ..
done


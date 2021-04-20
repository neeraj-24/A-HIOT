#!/bin/bash
cd /home/user/Downloads/plip-master/plip
for f in /home/user/DNN_RF/pipeline_validation/dud_e/Biological_space/validation_set/validation_pdbqt/validation_vs_output/complex_files_FPs/complex_files/complex_*.pdb; do
    s=`basename $f`
    echo Processing compound $f
    python plipcmd.py -f $f -o out_$s -x -t 
done
mv out* /home/user/DNN_RF/pipeline_validation/dud_e/Biological_space/validation_set/validation_pdbqt/validation_vs_output/complex_files_commom/PLIP_interactions_for_validation_complexs/

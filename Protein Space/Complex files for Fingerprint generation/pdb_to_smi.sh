#! /bin/bash


for f in complex_*.pdb; do
    b=`basename $f .pdb`
    echo Processing compound $b
    obabel -i pdb $b.pdb -o smi -O $b.smi
done

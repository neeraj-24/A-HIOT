#! /bin/bash


for f in complex_*.pdb; do
    b=`basename $f .pdb`
    echo Processing compound $b
    obabel -i pdb $b.pdb -o pdb -O $b.pdb
done

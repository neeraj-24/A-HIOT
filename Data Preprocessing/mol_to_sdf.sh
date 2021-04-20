#! /bin/bash


for f in NW_*.mol; do
    b=`basename $f .pdb`
    echo Processing compound $b
    obabel -i mol $b.mol -o sdf -O $b.sdf
done

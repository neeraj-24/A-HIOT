#! /bin/bash
for a in my_*; do
	d=`$a`
	cd $a
	echo copying pdb file
	cp ../receptor_cxcr4_A.pdb .
	cd ..
done


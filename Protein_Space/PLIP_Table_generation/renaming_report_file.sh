#! /bin/bash
for a in out_*; do
	d=`$a`
	cd $a
	echo accessing directory
	mv report.txt $a.txt
	rename 's/.pdb//' *.txt
	cd ..
done



#! /bin/bash
for a in my_*; do
	d=`$a`
	cd $a
	echo copying complex files
	cp complex_* ../complex_files_commom/
	cd ..
done


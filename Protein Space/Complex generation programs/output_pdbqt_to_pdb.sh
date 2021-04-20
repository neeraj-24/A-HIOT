#! /bin/bash
for a in my_*; do
	d=`$a`
	cd $a
	for f in *.pdbqt; do
		b=`basename $f .pdbqt`
		/home/user/MGLTools-1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24/./pdbqt_to_pdb.py -f $f -o 1st.pdb -v
	cd ..
done


done

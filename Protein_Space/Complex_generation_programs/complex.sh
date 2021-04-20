#! /bin/bash
for a in my_*; do
	d=`$a`
	cd $a
	echo processing complex
	cat receptor_cxcr4_A.pdb 1st.pdb | grep -v '^END   ' | grep -v '^END$' > complex_$a.pdb
	cd ..
done


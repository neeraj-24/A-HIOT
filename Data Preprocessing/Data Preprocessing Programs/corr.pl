$a=`head -1 $ARGV[0]`;
@arr=split(/\,/,$a);
$col=$#arr;
$c=0;
@square = 0;
for($i=1;$i<=$#arr+1;$i++)
{
		$m=`cut -d',' -f $i $ARGV[0]| awk '{if(\$0 > 0.90) print\$0}' | wc -l`;
		#$m1=`cut -d',' -f $i $ARGV[0]`;
		chomp $m;
		#print $m,"\n";
		if($m>40)
		{		
			$check[$c]=$i-1;
			$c++;
		}
		#print "\n";

}
open(fh,"$ARGV[0]");
while(<fh>)
{		chomp $_;
		@arr1="";
		@arr1=split(/\,/,$_);
		foreach $var(@check)
		{
			print @arr1[$var],"\,";
		}
		print"\n";
}

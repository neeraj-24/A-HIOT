$a=`head -1 $ARGV[0]`;
@arr=split(/\,/,$a);
$col=$#arr;
$c=0;
for($i=1;$i<=$#arr+1;$i++)
{
	$m=`cut -d',' -f $i $ARGV[0]| awk '{if(\$0 != 0) print\$0}' | wc -l`;
	$m1=`cut -d',' -f $i $ARGV[0]`;
	chomp $m;
	chomp $m1;
	$sum=0;
	$j=0;
	@line=split(/\n/,$m1);
	foreach $var2(@line)
	{
		$sum=$sum+$var2;
		$j++;
	}
	#print @line;
	$avg=$sum/$j;
	#print $avg;
	$ss=0;
	foreach $var3(@line)
	{
		$square=($var3-$avg)**2;
		$ss=$square+$ss;
	}
	$ss_avg=$ss/$j;
	$std_dev=sqrt($ss_avg);
	#	print "Std deviation for column $i is = $std_dev\n";
	if($m>40 && $std_dev > 2)
	{
		$check[$c]=$i-1;
		$c++;
	}

}
open(fh,"$ARGV[0]");
while(<fh>)
{
chomp $_;
@arr1="";
@arr1=split(/\,/,$_);
foreach $var(@check)
{
print @arr1[$var],"\,";
}
print"\n";
}

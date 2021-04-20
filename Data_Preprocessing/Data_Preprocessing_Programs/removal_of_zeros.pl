$a=`head -1 $ARGV[0]`;
@arr=split(/\,/,$a);
$col=$#arr;
$c=0;
for($i=1;$i<=$#arr+1;$i++)
{
$m=`cut -d',' -f $i $ARGV[0] | awk '{if(\$0 != 0) print\$0}' | wc -l`;
chomp $m;
if($m>40)
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

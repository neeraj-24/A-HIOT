$a=`head -1 $ARGV[0]`;
@arr=split(/\,/,$a);
$col=$#arr;
@arr1 = qw (apol nAtom nHeavyAtom nH nC ATS0v ATS1v ATS2v ATS3v ATS4v ATS5v ATS6v ATS7v ATS0e ATS1e ATS2e ATS3e ATS4e ATS5e ATS6e ATS7e ATS8e ATS0p ATS1 ATS2p ATS3p ATS4p ATS5p ATS6p ATS7p ATS0i ATS1i ATS2i ATS3i ATS4i ATS5i ATS6i ATS7i ATS8i ATSC0v ATSC0i SpAbs_DzZ SpMax_DzZ SpDiam_DzZ SpAD_DzZ SpMAD_DzZ EE_DzZ VR3_DzZ SpAbs_Dzm SpMax_Dzm SpDiam_Dzm SpAD_Dzm SpMAD_Dzm EE_Dzm VR3_Dzm SpAbs_Dzv SpMax_Dzv SpDiam_Dzv SpAD_Dzv SpMAD_Dzv EE_Dzv VR3_Dzv SpAbs_Dze SpMax_Dze SpDiam_Dze SpAD_Dze SpMAD_Dze EE_Dze VR3_Dze SpAbs_Dzp SpMax_Dzp SpDiam_Dzp SpAD_Dzp SpMAD_Dzp EE_Dzp VR3_Dzp SpAbs_Dzi SpMax_Dzi SpDiam_Dzi SpAD_Dzi SpMAD_Dzi EE_Dzi nBonds nBonds2 nBondsS bpol Sv Sse Spe Sare Sp Si CrippenMR SpMax_Dt SpDiam_Dt SpAD_Dt EE_Dt ECCEN);
$j=0;
for($i=1;$i<=$#arr+1;$i++)
{

foreach $ar(@arr1)
{
	if ($arr[$i] eq $ar)
	{
		$c[$j]=$i;
		$j++;
	
	}	
}
}

open(fh,"$ARGV[0]");
while(<fh>)
{
	chomp $_;
	@arr2=split(/\,/,$_);
	foreach $ar(@c)
	{
		print $arr2[$ar],"\,";
	}
print "\n";
}

close(fh);


use LWP::Simple;

sub menu {

	#石油価格取得 --- ここから (OLDバージョン)
	#$nymex = get("http://www.nymex.com/");
	#
	#@nymex = split(/>/,$nymex);
	#for($i = 0; $i <= $#nymex; $i++) {
	#	if($nymex[$i] =~ /span id="LastCL"/) {
	#		($oilprice) = $nymex[$i+1] =~ /(.*)<\/span/;
	#		last;
	#	}
	#}
	#石油価格取得 --- ここまで (OLDバージョン)

	#石油価格取得 --- ここから
	$nymex = get("http://content.barchart.com/cme/marketbox2.php?listchart=CL*1,NG*1,HO*1,RB*1,QM*1,QG*1,QH*1,PL*1,PA*1,GC*1,SI*1,HG*1,KA*1,SC*1\&listdata=CL*1,SC*1,HO*1,RB*1,NG*1,GC*1,SI*1,HG*1\&desc=Crude Oil,Natural Gas,Heating Oil,RBOB Gasoline,E-mini Crude Oil,E-mini Natural Gas,E-mini Heating Oil,Platinum,Palladium,Gold,Silver,Copper,Sugar,NYMEX Brent Crude Oil\&descdata=Crude Oil,Brent Crude,Heating Oil,RBOB Gasoline,Natural Gas,Gold,Silver,Copper\&width=220\&height=100");
	@nymex = split(/\n/,$nymex);
	for($i = 0; $i <= $#nymex; $i++) {
		if($nymex[$i] =~ /Crude Oil \(CL\)<\/a><\/td><td style="border-top: 1px solid #cccccc;" class="marketbox_last">.* <\/td>/) {
			($oilprice) = $nymex[$i] =~ /Crude Oil \(CL\)<\/a><\/td><td style="border-top: 1px solid #cccccc;" class="marketbox_last">(.*) <\/td>/;
			#$oilprice = $nymex[$i];
			last;
		}
	}
	#石油価格取得 --- ここまで








	# (特別) 石油価格をトップページに表示する --- ここから

	#$pathtmpl = "html/tmpl_index_top.html";
	#$pathtopindex = "../index.html";

	#$strtmpl = &ReadFileData($pathtmpl,3);
	#$strtmpl =~ s/_oilprice_/$oilprice/g;
	#&RecordFileData($pathtopindex,3,$strtmpl);

	# (特別) 石油価格をトップページに表示する --- ここまで


	# 出力表示 ---
	$K = join("","
		<table width='100%' height='80%'><tr><td $vac $ac>
		<font style='font-size: 60pt; font-weight: bold;'>_txtheadermenu000_</font>

		<p> <p> <p>

		<font style='font-size: 30pt; font-weight: bold; color: blue;'>_txtmenuoilprice_ : </font>
		<font style='font-size: 60pt; font-weight: bold; color: blue;'>$oilprice</font>

		<!--// <iframe height='150' frameborder='0' width='555' scrolling='no' marginheight='0' marginwidth='0' border='0' src='http://freeserv.dukascopy.com/chart/?ql=504&amp;interval=600&amp;points_number=500&amp;view_type=line&amp;width=553&amp;height=148&amp;osc_type=-1&amp;osc_height=100&amp;p1=2&amp;p2=3&amp;p3=7&amp;c=&amp;rfi=false&amp;show_labels=true&amp;show_border=true' name='DC'></iframe> //-->

		<p> <p>

		</td></tr></table>
	");

}

1;
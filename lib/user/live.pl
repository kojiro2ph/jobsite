
use LWP::Simple;

sub live {

	# recmeのipを取得 ---
	$liveip = &ReadFileData("../cgi-bin/recme.dat",3);

	if($form{'step'} eq "") {

		$K = &Blank("<table width='100%' height='80%'><tr><td $ac $vac> <img src='/jobsite/images/con1.gif'> <p> <p> <font style='font-size: 15pt; font-weight: bold;'>_txtlive001_</font> <p> (connecting to $liveip)</td></tr></table>","$ThisFile?act=live\&step=2",2);

	} elsif($form{'step'} eq "2") {


		$liveip = "$liveip:8080";

		$rtn = get("http://$liveip\/");

		if($rtn =~ /Java/i) {

			$K = join("","
				<table width='100%' height='80%' bgcolor='gray'><tr><td $vac $ac>
				<applet codebase='http://$liveip' code='Lv2View.class' width='640' height='480' border='1'>
				　　<param name='quality' value='50'/>
				　　<param name='password' value='disable'/>
				</applet>
				</td></tr></table>
			");

		} else {

			$K = &Blank("<table width='100%' height='80%'><tr><td $ac $vac> <img src='/jobsite/images/alert.png' width='150'> <p> <p> <font style='font-size: 15pt; font-weight: bold;'>_txtlive002_</font> </td></tr></table>");

		}

	}
}

1;
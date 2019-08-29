
use LWP::Simple;

sub Init_System {

	local($strtmp);

	$BODYBGCOLOR = "#FFFFFF";

	#ＳＱＬ初期化 ---
	&pInit_SQL;

	#ＳＱＬ接続 ---
	&pConnectSQL;

	&ExecSQL("set names utf8");

	#クッキー取得 ---
	&GetCookie;


	#認証処理の判別 ---
	if($form{'act'} eq "logout" or ($form{'act'} eq "expense" and $form{'substep'} eq "tb" and $form{'reportl2s'} eq "1")) {
		$noneed_pass_me = "1";
	}
	if($form{'act'} eq "" and $formdata{'Filedata_fdata'} ne "") {
		$form{'act'} = "file";
		$form{'upload'} = "1";
		$noneed_pass_me = "1";
	}



	# 認証　または　スルー　の判別場所 --- （※重要　）
	if($noneed_pass_me eq "1") {

		#
		# ここでは何もないです.
		#

		$lng = &GetBRLanguage(1);

	} else {

		# 認証エリア ---

		if($COOKIE{'HBJMS-cid'} eq "") {
			$cid = time;
			print &PutCookie("HBJMS","cid:$cid",90);
			$nye = "1";
			$lng = &GetBRLanguage(1);
		} else {
			$cid = $COOKIE{'HBJMS-cid'};

			@qfld = qw(eid ejid elng estpbyjid estpbyfolid esfbyjid);
			$q = "SELECT eid,ejid,elng,estpbyjid,estpbyfolid,esfbyjid FROM hbjms_cidmanagetb WHERE hbjms_cidmanagetb.cid = '$cid'";
			&ExecSQL($q);
			&GetValueFromSTH(2,"",*qfld);

			#個人プロジェクト名取得 ---
			$q = "SELECT jname AS ejname FROM hbjms_jtb WHERE jid = '$ejid'";
			&ExecSQL($q);
			$ejname = &GetValueFromSTH(1,"ejname");

			#言語設定 ---
			if($elng ne "") { $lng = $elng; }
			if($lng eq "") {
				$lng = &GetBRLanguage(1);
				$q = "UPDATE hbjms_cidmanagetb SET elng = '$lng' WHERE cid = '$cid'";
				&ExecSQL($q);
			}

			#ユーザーＩＤ判別 ---
			if($eid eq "") {
				$nye = "1";
			} else {

				#最終アクセス時間を記録 ---
				$q = "UPDATE hbjms_cidmanagetb SET llgndt = NOW() WHERE cid = '$cid'";
				&ExecSQL($q);

				$LOGININFO1 = "<font style='font-size:10pt; font-weight: bold;'>($eid)</font>";
				if($ejname ne "") {
					if(length($ejname) > 20) {
						$tmp_pt = "8";
					} else {
						$tmp_pt = "12";
					}
					$LOGININFO1 .= " - <font style='font-size:" . $tmp_pt . "pt; font-weight: bold; background-color: LightGreen; Padding: 2px;'>$ejname</font> <font style='font-size: 8pt;'>(<a href='$ThisFile?act=setj'>change</a>)</font>";
				}


				@armenu = qw(menu tp live file words schedule report expense logout);
				for($i = 0; $i <= $#armenu; $i++) {
					if($armenu[$i] eq "file") {
						$armenuext = "\&step=w";
					} else {
						$armenuext = "";
					}
					push(@strmenu,"<a href='$ThisFile?act=$armenu[$i]$armenuext' target='_top'>_txtheadermenu" . sprintf("%03d",$i) . "_</a>");
				}
				$LOGININFO2 = join(" - ",@strmenu);

				#ログインインフォ文字列作成 ---
				$LOGININFO = join("","
					<table border='0' style='font-size: 10pt;' $cp{'0'} $cs{'0'}>
					<tr><td>$LOGININFO1</td><td rowspan='3'>\&nbsp;\&nbsp;\&nbsp;</td><td rowspan='3'><a href='$ThisFile?act=setj\&step=lng'><img src='/jobsite/images/flg$lng\.gif' border='0' title='change language' alt='change language'></a></td></tr>
					<tr><td><font style='font-size: 2pt;'>\&nbsp;</font></td></tr>
					<tr><td>$LOGININFO2</td></tr>
					</table>

					
				");
			}
		}

	# noneed_pass_me 区切り終了
	}

	#表示系をととのえる ---
	$TITLE = $INI{'TEXT-txt_main_header_title' . $lng};
	$HEADERTITLE = $INI{'TEXT-txt_main_header_title' . $lng};

	#個人のプロジェクトが設定してない場合 ---
	if($ejid eq "" and $nye ne "1" and $noneed_pass_me ne "1") {
		if($form{'act'} eq "setj" and $form{'step'} eq "2") {
		} else {
			$form{'act'} = "setj";
			$form{'step'} = "";
		}
	}

	#新規ユーザーである又はクッキーが切れている場合 ---
	if($nye eq "1") {
		$form{'act'} = "p0";
	}

	#処理関数の呼び出し ---
	$form{'act'} = "p0" if($form{'act'} eq "");
	require "lib/user/$form{'act'}.pl";
}


sub Run {
	&{$form{'act'}};
}

sub Quit_System {
	&DisconnectSQL;
}

sub PB {
	print &PH;

	if($KFULL eq "1") {
		print $K;
	} else {
		$HEADER = &ConvVal(&ReadFileData("html/user_header.html",3));
		$FOOTER = &ConvVal(&ReadFileData("html/user_footer.html",3));
		$K = &ConvVal(&ReadFileData("html/user_frame.html",3));
		print &ConvVal($K);
	}

}


########################################
# ＳＱＬ接続
########################################

sub pConnectSQL {

	#ＳＱＬ接続
	&ConnectSQL("mysql",$mysql_dbn,$mysql_host,"3306",$mysql_user,$mysql_pass,{'RaiseError'=>1, 'mysql_enable_utf8'=>1});

}

########################################
# ＳＱＬ初期化
########################################

sub pInit_SQL {

	$mysql_dbn = "hamadaboiler-com00001";

	if($ENV{'HTTP_HOST'} eq "xxx") {
		$mysql_host	= "";
		$mysql_user	= "";
		$mysql_pass	= "";
	}
	elsif($ENV{'HTTP_HOST'} eq "www.honey-land.jp") {
		$mysql_host	= "";
		$mysql_user	= "";
		$mysql_pass	= "";
	}
	else {
		$mysql_host	= "localhost";
		$mysql_user	= "hamadaboiler-com";
		$mysql_pass	= "zt8JaToF";
	}

}

########################################

sub Err001 {
	local($msg) = @_;

	$K = &ConvVal(&JE(&ReadFileData("html/err001.html",3)));
	&PB;

	&Quit_System;

	exit(0); 
}

sub Impact001 {
	local($strtmp) = @_;

	return "<FONT class='F10R'>$strtmp</FONT>";
}

sub Impact002 {
	local($strtmp) = @_;

	return "<FONT class='F14R'><B>$strtmp</B></FONT>";
}

sub Impact {
	local($strtmp) = @_;
	return $strtmp;
}

sub Blank {

	local($msg,$path,$sec) = @_;

	if($path eq "") {

		return &ConvVal(&ReadFileData("html/user_blank1.html",3));

	} else {

		return &ConvVal(&ReadFileData("html/user_blank2.html",3));


	}

}

######################################################################
# 
# SQL - ライブラリ
#
######################################################################

sub MakeSelFromTable {
	local($mode,$tname,$sname,$s1,$s2) = @_;
	local(@s1,@s2);

	if($mode eq 1) {
		&ExecSQL("SELECT $s1 from $tname $qWHERE $qORDERBY");
		@s1= &MakeArrayBySpecCat($s1);
		&ExecSQL("SELECT $s2 from $tname $qWHERE $qORDERBY");
		@s2 = &MakeArrayBySpecCat($s2);

		return &MakeSelectionByStrArray(2,$sname,*s1,*s2);
	}

}

######################################################################
# 
# 翻訳系 - ライブラリ
#
######################################################################


sub GetBRLanguage {

	local($mode) = @_;
	local($strlng);

	if($mode eq 1) {

		if($ENV{'HTTP_ACCEPT_LANGUAGE'} =~ /en/i) {
			$strlng = "en";
		} elsif($ENV{'HTTP_ACCEPT_LANGUAGE'} =~ /cn/i) {
			$strlng = "cn";
		} elsif($ENV{'HTTP_ACCEPT_LANGUAGE'} =~ /jp/i) {
			$strlng = "jp";
		} elsif($ENV{'HTTP_ACCEPT_LANGUAGE'} =~ /tw/i) {
			$strlng = "tw";
		} else {
			$strlng = "en";
		}

		return $strlng;

	}

}

sub TT {
	local($mode,$dlng,$ctt) = @_;
	local($strtmp,$tmplng,$tmplp,$octt,$grs);

	if($mode eq 1) {

		#空ならそのまま返す ---
		if($ctt eq "") {
			return $ctt;
		}

		$octt = $ctt;

		$ctt = &my_urlencode_utf8($ctt);

		#return $ctt;

		$grs = get("http://ajax.googleapis.com/ajax/services/language/detect?v=1.0&q=$ctt");
		($tmplng) = $grs =~ /\"language\"\:\"(.*?)\"/;

		#マレーシア語と判斷した場合はインドネシア語にする ---
		if($tmplng eq "ms") {
			$tmplng = "id";
		}

		#return $tmplng;

		#if($tmplng eq "zh-CN" or $tmplng eq "zh-TW") {
		#	$tmplp = "$tmplng\|en";
		#} elsif($tmplng eq "en") {
		#	$tmplp = "$tmplng\|zh-TW";
		#} elsif($tmplng eq "ja") {
		#	$tmplp = "$tmplng\|zh-TW";
		#}

		#個人の言語とgoogle用の言語定義を設定 ---
		if($lng eq "en") {
			$p4g = "en";
		} elsif($lng eq "cn") {
			$p4g = "zh-CN";
		} elsif($lng eq "tw") {
			$p4g = "zh-TW";
		} elsif($lng eq "jp") {
			$p4g = "ja";
		}

		#指定するターゲットがあれば再指定する ---
		if($sp4g ne "") {
			$p4g = $sp4g;
		}

		#フィルタリング ---
		if($tmplng ne $p4g) {
			$tmplp = "$tmplng\|$p4g";
		} else {
			return $octt;
		}

		#翻訳実行 ---
		$grs = get("http://ajax.googleapis.com/ajax/services/language/translate?v=1.0\&q=$ctt\&langpair=$tmplp");
		#return $grs;
		($strtmp) = $grs =~ /\"translatedText\"\:\"(.*?)\"/;
		$strtmp = decode('utf8',$strtmp);

		if($nama eq "1") {
			return $strtmp;
		} else {
			return $octt . " <font color='red'>($strtmp)</font>";
		}

	}

}

######################################################################
# 
# 文字列系 - ライブラリ
#
######################################################################

sub my_urlencode_utf8 {

	my($tmp) = @_;

	$tmp = Encode::encode('utf8',$tmp);
	$tmp =~ s/([^￥w])/'%'.unpack("H2", $1)/ego;
	$tmp =~ tr/ /+/;
	$tmp = Encode::decode('utf8',$tmp);

	return($tmp);

}

sub my_utf8_pe {

	my($tmp) = @_;

	$tmp =~ tr/\s//;
	$tmp = Encode::encode('utf8',$tmp);
	#$tmp =~ s/([^￥w])/'%'.unpack("H2", $1)/ego;
	$tmp = &URLEncode($tmp);
	$tmp = Encode::decode('utf8',$tmp);

	return($tmp);

}

######################################################################
# 
# ファイル - ライブラリ
#
######################################################################

sub Fsize2Fsize {
	local($size) = @_;

	if($size >= 1000000) {
		$size = &Round($size / 1000000,1);
		return "$size MB";
	} elsif($size >= 1000) {
		$size = &Round($size / 1000,1);
		return "$size KB";
	} elsif ($size < 1000) {
		return "$size Bytes";
	}
}

1;
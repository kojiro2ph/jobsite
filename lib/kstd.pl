
#-----------------------------------------------------------------------
#
#
#
#
#
#
#
#
#
#
#-----------------------------------------------------------------------

#　@(f)
#
#　機能　	：	ブラウザ引数文字コード変換処理
#
#　引数　	：	変換文字コード
#
#　返り値	：	なし
#
#　機能説明　	：	ブラウザからの文字列を初期化する
#
#　備考　	：	借り物です(^^ ;

sub Init_Form {
	local($query, @assocarray, $assoc, $property, $value, $charcode, $method);
		$charcode = $_[0];
		$method = $ENV{'REQUEST_METHOD'};
		$method =~ tr/A-Z/a-z/;

		#-------------------------------
		if($ENV{'CONTENT_TYPE'} =~ /multipart/) {
			&Init_Multipart($charcode);
			return 0;
		}
		#-------------------------------

		if ($method eq 'post') {
			read(STDIN, $query, $ENV{'CONTENT_LENGTH'});
		} else {
	  		$query = $ENV{'QUERY_STRING'};
		}
#print &PH;
#print $query;
#exit(0);
		@assocarray = split(/&/, $query);
		foreach $assoc (@assocarray) {
			($property, $value) = split(/=/, $assoc);
			$value =~ tr/+/ /;
			$value =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
			$enc = guess_encoding($value);
			if ( ref $enc ) { $value = decode ( $enc->name , $value ); }
			#$value = encode( "utf8", decode( "Guess", join( undef, $value ) ) );
			#&jcode'convert(*value, $charcode);
			$value =~ s/\r//g;
			$form{$property} = $value;
	    	}
}

#　@(f)
#
#　機能　	：	multipart/form-data のデータを form に格納する
#
#　引数　	：	なし
#
#　返り値	：	なし
#
#　機能説明　	：	ブラウザからの文字列を初期化する
#
#　備考　	：	自前です(^^ ;

sub Init_Multipart {
	local($i,$key,$dum,$boundary,$fname,$formdata,$formhead,$formbody,$charcode,@formdata);

	$charcode = $_[0];

	($dum,$boundary) = $ENV{'CONTENT_TYPE'} =~ /(.*)boundary=(.*)/;
	$formdata .= $_ while(<STDIN>);

	#&RecordFileData("tim6_" . time,3, $boundary);

	#print &PH;
	#print $formdata;
	#exit(0);
	@formdata = split(/--$boundary/,$formdata);
	#print &Impact("$#formdata<hr>");

	for($i = 0; $i <= $#formdata; $i++) {

		#print "$formdata[$i]<br>";

		if($ENV{"HTTP_HOST"} =~ /www/) {

			#($formhead,$formbody) = split(/\r\n\r\n/,$formdata[$i],2);

	#&RecordFileData("tim3_" . time,3, $formdata[$i]);

			($x) = $formdata[$i] =~ /filename="(.*?)"/;
			$formheadfname = $x;
			#IEとFirefoxのファイルの形式が違うためここで整理する ---
			if($formheadfname =~ /\\/) {
				@x = split(/\\/,$formheadfname);
				$formheadfname = $x[$#x];
			}
			$x2 = "fn" . $i;
			$formdata[$i] =~ s/filename="(.*?)"/filename="$x2"/g;


			($formhead,$formbody) = split(/\r\n\r\n/,$formdata[$i],2);


			#($formhead,$formbody) = $formdata[$i] =~ /(.*)\r(.*)/m;

	#&RecordFileData("tim11_$i\_" . time,3, $x);

		} else {
			($formhead,$formbody) = split(/\n\n/,$formdata[$i],2);
		}

		#データファイルならば
		if($formhead =~ /filename/) {

			#&Err001("o");

			($key) = $formhead =~ /name="(.*?)"/;
			($fname) = $formhead =~ /filename="(.*?)"/;
			if($fname =~ /\\/) {
				($dum,$fname) = $fname =~ /(.*)\\(.*)/;
			}

			$enc = guess_encoding($fname);
			if ( ref $enc ) { $fname = decode ( $enc->name , $fname ); }

			#$formdata{"$key\_fname"} = $fname;
			$formdata{"$key\_fname"} = $formheadfname;
			$formdata{"$key\_fdata"} = $formbody;

			#print "$fred $fname<hr> $formbody $fc";
			#print "$fred $formhead $fc";
			#exit(0);
		}
		#変数ならば
		else {
			($key) = $formhead =~ /name="(.*)"/;
			chop($formbody);

			#$formbody =~ s/[\r|\n]//g;

			#print "<B>$key = $formbody</b><br>";

			#renovate at ITS 2002/01/21 K.Hamada EUCに変換する

			$formbody =~ tr/+/ /;
			$formbody =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
			#&jcode'convert(*formbody, $charcode);

			$enc = guess_encoding($formbody);
			if ( ref $enc ) { $value = decode ( $enc->name , $formbody ); }

			$formbody =~ s/\r//g;

			$form{$key} = $formbody;
		}
	}



}



#　@(f)
#
#　機能　	：	ファイル読込処理
#
#　引数　	：	$fname	---	ファイル名（パス抜き）
#			$way	---	オプション 
#					(1)文字列で返す
#					(2)配列で返す
#
#　返り値	：	ファイルの文字列
#
#　機能説明　	：	ファイルデータを読み込んで返す
#
#　備考　	：	文字コード変換をしないで返す

sub ReadFileData {
	local($fname,$way) = @_;
	local(@strarray,$strline,$strtmp,$DebugPath);

	#open(DB,"$fname");
	open(DB, "<:utf8", $fname);
	@strarray = <DB>;
	close(DB);

	if($way eq 1) {
		$strline = join("",@strarray);
		return "$strline";
	} elsif($way eq 2) {
		return @strarray;
	} elsif($way eq 3) {
		$strline = join("",@strarray);
		return "$strline";
	}
}

#　@(f)
#
#　機能　	：	ファイル書込処理
#
#　引数　	：	$fname		---	ファイル名（パス抜き）
#			$way		---	オプション 
#						(1)各文字列配列に改行を付加して書き込む 
#						(2)各文字列配列をそのまま書き込む 
#						(3)文字列をそのまま書き込む 
#			$strline 	---	文字列変数
#			@strArray	---	文字列配列 
#
#　返り値	：	なし
#
#　機能説明　	：	ファイルデータに引数の文字列または文字列配列を書き込む
#
#　備考　	：	文字コード変換をしないで書き込む

sub RecordFileData {
	local($fname,$way,$strline,@strArray) = @_;
	local($strtmp);


	
	if($way eq 1) {
		open(DB,">$fname");
		foreach $strtmp (@strArray) {
			if($strtmp !=~ /\n$/) {
				$strtmp = join("",$strtmp,"\n");
			}
			print DB "$strtmp";	
		}
		close(DB);
	} elsif($way eq 2) {
		open(DB,">$fname");
		$strtmp = join("",@strArray);
		print DB "$strtmp";	
		close(DB);
	} elsif($way eq 3) {
		open(DB,">:utf8","$fname");
		print DB "$strline";	
		close(DB);
	} elsif($way eq 4) {
		open(DB,">>$fname");
		print DB "$strline";	
		close(DB);
	}

	return;
}

#　@(f)
#
#　機能　	：	サーバー時刻を取得する
#
#　引数　	：	なし
#
#　返り値	：	年月日時分秒文字列
#
#　機能説明　	：	現在の日付・時間を":"くぎりで返す
#
#　備考　	：	日本と海外では時間が違うので要注意

sub GetDateString {
	local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst,$datestr);
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$mon++;
		
	if($sec < 10) {$sec = "0$sec";};
	if($min < 10) {$min = "0$min";};
	if($hour < 10) {$hour = "0$hour";};
	if($mday < 10) {$mday = "0$mday";};
	if($mon < 10) {$mon = "0$mon";};
	if($year < 99) {$year = $year + 2000}
	else {$year = $year + 1900;};

	$datestr = "$year:$mon:$mday:$hour:$min:$sec";

	return $datestr;
}

#　@(f)
#
#　機能　	：	ヘッダー文字列作成処理
#
#　引数　	：	なし
#
#　返り値	：	ＨＴＭＬヘッダ文字列
#
#　機能説明　	：	ＨＴＭＬヘッダの文字列を返す
#
#　備考　	：	将来は text/html 以外にもやる予定

sub PH {
	return "Content-Type: text/html\n\n";

	local($strtmp);
	#if($ENV{'HTTP_ACCEPT_ENCODING'}=~/gzip/ and $ENV{"HTTP_HOST"} =~ /www/){
	#        print "Content-type: text/html; charset=utf-8\n";
	#        print  "Content-encoding: gzip\n\n";
	#        open(STDOUT,"| /usr/bin/gzip -1 -c");
	#		return "";
	#}else{
		#return encode('shiftjis',"Content-type: text/html; charset=utf-8\n\n");
	#}
}

#　@(f)
#
#　機能　	：	更新ページ文字列作成処理
#
#　引数　	：	$url	--- 	ジャンプ先ＵＲＬ（http:// から記入）
#			$sec	--- 	更新アクションの間　（$sec秒)
#			$str 	--- 	ページに表示する文字列
#
#　返り値	：	ＨＴＭＬ文字列
#
#　機能説明　	：	ＨＴＭＬの文字列を返す
#
#　備考　	：	特になし

sub MakeRefresh {
	local($url,$sec,$str) = @_;
	local($strline);

	$strline = "<html><head><title>更新中・・・</title><META HTTP-EQUIV='Content-Type' Content=\"text/html; charset=x-euc-jp\"><META HTTP-EQUIV='Refresh' Content=\"$sec ; url='$url'\"></head><body>$str</body></html>";
	
	return $strline;
}

#　@(f)
#
#　機能　	：	ＨＴＭＬ用文字列変換処理
#
#　引数　	：	$strtmp	--- 	変換する文字列
#
#　返り値	：	ＨＴＭＬ文字列
#
#　機能説明　	：	一般文字列をＨＴＭＬ用文字列に変換する
#
#　備考　	：	特になし

sub ConvHTMLTag {
	local($strtmp) = @_;

	$strtmp =~ s/ /\&nbsp;/g;
	$strtmp =~ s/</\&lt;/g;
	$strtmp =~ s/>/\&gt;/g;
	$strtmp =~ s/\r\n/\n/g;
	$strtmp =~ s/\n/<br>/g;
	$strtmp =~ s/<br><br>/<br> <br>/g;
	$strtmp =~ s/_N_/<br>/g;

	return $strtmp;
}

#　@(f)
#
#　機能　	：	時刻文字列変換処理
#
#　引数　	：	$strtmp	--- 	変換する文字列
#			$way	---	オプション
#					(1)年月日時で返す
#					(2) 
#					(3)
#
#　返り値	：	時刻文字列
#
#　機能説明　	：	データ等の暗号化した時刻文字列をある規則の文字列に変換する
#
#　備考　	：	特になし

sub ConvDateString {
	local($strtmp,$way,$sp) = @_;
	local($year,$mon,$date,$hour,$min,$sec);

	$sp = "_" if($sp eq "");

	if($way eq 1) {
		($year,$mon,$date,$hour,$min,$sec) = split(/$sp/,$strtmp);
		return "$year年$mon月$date日$hour時";
	} elsif($way eq 2) {
		($year,$mon,$date,$hour,$min,$sec) = split(/$sp/,$strtmp);
		return "$year年$mon月$date日$hour時$min分";
	}
}

#　@(f)
#
#　機能　	：	METAタグ文字列作成処理
#
#　引数　	：	$way ---	オプション
#					(euc)charset を ＥＵＣコードにする
#
#　返り値	：	METAタグ文字列
#
#　機能説明　	：	METAタグ文字列を返す
#
#　備考　	：	

sub PrintMETA {
	local($way) = @_;
	local($strtmp);

	if($way eq "euc") {
		$strtmp = q#<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=x-euc-jp">#;
		return $strtmp;
	}
}

#　@(f)
#
#　機能　	：	設定ファイル初期化処理
#
#　引数　	：	$mode ---	オプション
#					(1)標準モード
#					(2)セクション内の文字列を返す
#			$fname ---	ファイル名
#			$section ---	セクション
#　返り値	：	なし、文字列
#
#　機能説明　	：	[SECTION] KEY = VAL のフォーマットを%hash{SECTION-KEY} に格納する
#
#　備考　	：	

sub InitINIData {
	local($mode, $fname, $section) = @_;
	local($i,$strline,$strtmp,$MatchFlag,$StrCurSection,$StrCurKey,$StrCurVal,$StrCurSecKey,@strarray);


	#------------------------
	#	標準モード
	#------------------------

	if($mode eq 1) {
		$strline = &ReadFileData($fname, 1);	#設定ファイルの読み込み
		$strline = $strline;
		$strline =~ s/\r//g;
		@strarray = split(/\n/,$strline);		#改行ごとに区切る
		#print &PH;
		#設定ファイル文字列を 連想配列 INIData に格納するループ　--- 開始 ---
		for($i = 0; $i <= $#strarray; $i++) {
			#セクション初期化・及び変更
			if($strarray[$i] =~ /\[.*\]/) {
				#print "Section:$strarray[$i]<br>\n";	#デバグ用
				$strarray[$i] =~ s/(\[|\])//g;		#中括弧をはずす
				$StrCurSection = $strarray[$i];		#カレントセクション変数の格納する
				next;
			#キーと値のの初期化
			} elsif($strarray[$i] =~ /.*=.*/) {
				$strarray[$i] =~ s/(\t|;.*|\/\*.*\*\/)//g;	#タブ・スペース・コメントを除去する
				($StrCurKey,$StrCurVal) = split(/=/,$strarray[$i],2);	#キーと値に分ける
				#print "Key:$StrCurKey Value:$StrCurVal<br>\n";		#デバグ用
				$StrCurSecKey = join("",$StrCurSection,"-",$StrCurKey);	#文字列 -> "キー-値"を作る
				#print "MainKey:$StrCurSecKey<br>\n";		#デバグ用
				$StrCurVal = &TrimL($StrCurVal);	#NEW
				$StrCurVal =~ s/(^"|"$)//g;		#両恥に " があった場合取り除く
				$INIData{$StrCurSecKey} = $StrCurVal;	#連想配列に格納する
				${$StrCurKey} = $StrCurVal;
			}
		}
		#設定ファイル文字列を 連想配列 INIData に格納するループ　--- 終了 ---

		return %INIData;

	#------------------------
	#	ＨＴＭＬモード
	#------------------------
	} elsif($mode eq 2) {

		$MatchFlag = 0;
		$strtmp = "";

		$strline = &ReadFileData($fname, 1);	#設定ファイルの読み込み
		$strline = &JE($strline);
		$strline =~ s/\r//g;
		@strarray = split(/\n/,$strline);		#改行ごとに区切る


		#設定ファイル文字列を 連想配列 INIData に格納するループ　--- 開始 ---
		for($i = 0; $i <= $#strarray; $i++) {
			if($MatchFlag eq 0) {
				#セクション初期化・及び変更
				if($strarray[$i] =~ /\[.*\]/) {
					#print "Section:$strarray[$i]<br>\n";	#デバグ用
					$strarray[$i] =~ s/(\[|\])//g;		#中括弧をはずす
					#print "$strarray[$i] $section<br>";	#デバグ用
					if($strarray[$i] eq $section) {
						$MatchFlag = 1;
						#print "match";	#デバグ用
					}
				}
				
				next;
			} elsif($MatchFlag eq 1) {
				if($strarray[$i] =~ /^\[.*\]/) {
					last;
				} else {
					$strtmp = join("",$strtmp,$strarray[$i],"\n");
				}
			}
		}
		#設定ファイル文字列を 連想配列 INIData に格納するループ　--- 終了 ---


		return $strtmp;
	}
}

#　@(f)
#
#　機能　	：	指定数値フォーマット変換処理
#
#　引数　	：	$mode ---	オプション
#					(1)４桁数字文字列の数字化 (例：0234 -> 234) 
#					(2)数字文字列を指定した桁の文字列に変換
#			$str ---	数字
#			$cmd01 ---	コマンド１
#			$cmd02 ---	コマンド２
#
#　返り値	：	数字
#
#　機能説明　	：	
#
#　備考　	：	

sub Sprint {
	local($mode,$str,$cmd01,$cmd02) = @_;
	local($Flg,$i,$j,$k,$strtmp,@strarray);

	# ４桁数字文字列の数字化 (例：0234 -> 234) 
	if($mode eq 1) {
		#$Flg = 0;
		#$strtmp = "";
		#
		#@strarray = split(//,$str);
		#
		#for($i = 0; $i <= $#strarray; $i++) {
		#	if(($strarray[$i] eq 0) && $Flg eq 0) {
		#	
		#	} else {
		#		$strtmp = join("",$strtmp,$strarray[$i]);
		#		if($Flg eq 0) {
		#			$Flg = 1;
		#		}
		#	}
		#}

		$strtmp = $str + 0;
	}
	# 数字文字列を指定した桁の文字列に変換
	elsif($mode eq 2) {
		#$j = $cmd01 - length($str);
		#
		#$strtmp = $str;
		#
		#for($i = 1; $i <= $j; $i++) {
		#	$strtmp = join("0","",$strtmp);
		#}

		$strtmp = sprintf("%0$cmd01\d",$str);
	}

	return $strtmp;
}

#　@(f)
#
#　機能　	：	ＣＳＶファイル読み込み
#
#　引数　	：	$mode ---	オプション
#					(1)連想配列に格納する
#			$fname ---	ファイル名
#
#
#　返り値	：	連想配列
#
#　機能説明　	：	
#
#　備考　	：	

sub ReadCSVFile {
	local($mode,$fname) = @_;
	local($i,$j,$k,$strCSVKey,$InValFlag,$strline,@strarray,@chararray);

	if($mode eq 1) {

		$InValFlag = 0;

		$strline = &ReadFileData($fname,1);
		#ＥＵＣに変換する
		&jcode'convert(*strline,'euc');

		@strarray = split(/\n/,$strline);
	
		for($i = 0;$i <= $#strarray; $i++) {
			$strarray[$i] =~ s/;.*//g;
			$strarray[$i] =~ s/""/_DBLAP_/g;
			@chararray = split("",$strarray[$i]);

			for($j = 0; $j <= $#chararray; $j++) {
				if($chararray[$j] eq "\"") {
					if($InValFlag eq 0) {
						$InValFlag = 1;
					} elsif($InValFlag eq 1) {
						$InValFlag = 0;
					}
					next;
				} else {
					if($chararray[$j] eq ",") {
						#区切りカンマの場合
						if($InValFlag eq 0) {
						#値カンマの場合
						} elsif($InValFlag eq 1) {
							$chararray[$j] =~ s/$chararray[$j]/_VALKAM_/g;
						}
					}
				}
			}

			$strarray[$i] = join("",@chararray);
			$strarray[$i] =~ s/"//g;

			#デバグ用
			if($strarray[$i] ne "") {
				#print "$f2<b>$strarray[$i]</b>$fc<br>";
			}


			@valarray = split(/,/,$strarray[$i]);

			for($k = 0;$k <= $#valarray; $k++) {
				$strCSVKey = join("",$i,"_",$k);
				$valarray[$k] =~ s/_DBLAP_/"/g;
				$valarray[$k] =~ s/_VALKAM_/,/g;

				#print "CSVKey : $strCSVKey CSVVal : $valarray[$k]<br>";

				$CSVData{$strCSVKey} = $valarray[$k];
			}

			$strCSVKey = join("","MAX","_",$i);
			$CSVData{$strCSVKey} = $#valarray;
			
		}

		$strCSVKey = "MAXRECORD";
		$CSVData{$strCSVKey} = $#strarray;

		return %CSVData;
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

#sub ConvOpenFileString {
#	local($targetURL, $curURL) = @_;
#	local($i,$cnt,$strT,$strC,$strSRV);
#
#
#	$strSRV = join("","http://",&DetectSrvName($curURL),"/");
#	$curURL =~ s/$strSRV//g;
#	($curURL,$dum) = split(/\?/,$curURL);
#	$cnt = &CountChar(1,$curURL,"/");
#
#	$strtmp = $targetURL;
#
#	for($i = 0; $i < $cnt; $i++) {
#		$strtmp = join("","../",$strtmp);
#	}
#
#	return $strtmp;
#}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

#sub DetectSrvName {
#	local($str) = @_;
#	local($strtmp,@strarray);
#	
#	$str =~ s/http:\/\///g;
#	@strarray = split(/\//,$str);
#
#	$strtmp = $strarray[0];
#
#	#$strtmp = join("",$strarray[0],"/");
#
#	return $strtmp;
#}

#　@(f)
#
#　機能　	：	指定文字カウント処理
#
#　引数　	：	$mode ---	オプション
#					(1)標準
#			$str ---	探すところの文字列
#			$charF ---	カウントする文字
#
#　返り値	：	一致数
#
#　機能説明　	：	
#
#　備考　	：	

sub CountChar {
	local($mode,$str,$charF) = @_;
	local($i,$cnt,@strarray);

	if($mode eq 1) {
		$cnt = 0;
		@strarray = split(//,$str);

		for($i = 0; $i <= $#strarray; $i++) {
			if($strarray[$i] eq $charF) {
				$cnt++;
			}
		}

		$strtmp = $cnt;
	}

	return $strtmp;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

#sub GetURLContent {
#	local($strT) = @_;
#	local($strtmp,$tmp01);
#
#	$tmp01 = &DetectSrvName($ENV{'HTTP_REFERER'});
#
#	if($strT =~ /$tmp01/i) {
#		$StrLink = &ConvOpenFileString($strT,$ENV{'HTTP_REFERER'});
#		$strtmp = &ConvHTMLTag(&ReadFileData($StrLink,1));
#	} else {
#		$strtmp = get($strT);
#	}
#	
#
#	return $strtmp;
#}

#　@(f)
#
#　機能　	：	頭の空白を削除する
#
#　引数　	：	$strtmp ---	文字列
#
#　返り値	：	削除した文字列
#
#　機能説明　	：	
#
#　備考　	：	

sub TrimL {
	local($strtmp) = @_;
	local($i, @strarray);

	#@strarray = split("",$strtmp);
	#
	#for($i = 0; $i <= $#strarray; $i++) {
	#	if($strarray[$i] eq " ") {
	#		splice(@strarray, $i, 1);
	#		$i--;
	#	} else {
	#		last;
	#	}
	#}
	#
	#$strtmp = join("",@strarray);

	$strtmp =~ s/^\s+//g;

	return $strtmp;
}

#　@(f)
#
#　機能　	：	文字をはさむ
#
#　引数　	：	$mode ---	オプション
#					(1)標準
#			$str ---	中央の文字
#			#substr ---	端の文字
#
#　返り値	：	文字列
#
#　機能説明　	：	
#
#　備考　	：	

sub SandWitch {
	local($mode,$str,$substr) = @_;
	local($strtmp);


	if($mode eq 1) {
		$strtmp = join("",$substr,$str,$substr);
	}

	return $strtmp;
}

#　@(f)
#
#　機能　	：	ＥＵＣコード変換
#
#　引数　	：	$strtmp ---	文字列
#
#　返り値	：	文字列
#
#　機能説明　	：	
#
#　備考　	：	

sub JE {
	local($strtmp) = @_;

	#&jcode'convert(*strtmp, 'euc');

	return $strtmp;
}

#　@(f)
#
#　機能　	：	ＳＨＩＦＴ－ＪＩＳコード変換
#
#　引数　	：	$strtmp ---	文字列
#
#　返り値	：	文字列
#
#　機能説明　	：	
#
#　備考　	：	

sub JS {
	local($strtmp) = @_;

	#&jcode'convert(*strtmp, 'sjis');

	return $strtmp;
}

# From Here Start 2000/8/11

#ＨＴＭＬタグ変数初期化

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub Init_Tag {
	$f1 				= "<font size=\"1\">";
	$f2 				= "<font size=\"2\">";
	$f3 				= "<font size=\"3\">";
	$f4 				= "<font size=\"4\">";
	$f5 				= "<font size=\"5\">";
	$f6 				= "<font size=\"6\">";
	$f7 				= "<font size=\"7\">";
	$f8 				= "<font size=\"8\">";
	$fred  				= "<font color=\"red\">";
	$fpink  			= "<font color=\"pink\">";
	$fblue  			= "<font color=\"blue\">";
	$fwhite  			= "<font color=\"white\">";
	$fblack  			= "<font color=\"black\">";
	$flblue  			= "<font color=\"lblue\">";
	$fb  				= "<b>";
	$fi  				= "<i>";
	$fc  				= "</font>";

	$al  				= "align=\"left\"";
	$ar  				= "align=\"right\"";
	$am  				= "align=\"center\"";
	$ac  				= "align=\"center\"";
	$vab 				= "valign=\"bottom\"";
	$vat 				= "valign=\"top\"";
	$vam 				= "valign=\"middle\"";


	$t				= "<table>";
	$tc 				= "</table>";

	$htdoc				= "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">";

	%wper	= (
		10 => "width=\"10%\"",
		20 => "width=\"20%\"",
		30 => "width=\"30%\"",
		40 => "width=\"40%\"",
		50 => "width=\"50%\"",
		60 => "width=\"60%\"",
		70 => "width=\"70%\"",
		80 => "width=\"80%\"",
		90 => "width=\"90%\"",
		100 => "width=\"100%\""
	);

	%wpix	= (
		10 => "width=\"10\"",
		20 => "width=\"20\"",
		30 => "width=\"30\"",
		40 => "width=\"40\"",
		50 => "width=\"50\"",
		60 => "width=\"60\"",
		70 => "width=\"70\"",
		80 => "width=\"80\"",
		90 => "width=\"90\"",
		100 => "width=\"100\""
	);


	%cp	= (
		0 => "cellpadding=\"0\"",
		1 => "cellpadding=\"1\"",
		2 => "cellpadding=\"2\"",
		3 => "cellpadding=\"3\"",
		4 => "cellpadding=\"4\"",
		5 => "cellpadding=\"5\"",
		6 => "cellpadding=\"6\"",
		7 => "cellpadding=\"7\"",
		8 => "cellpadding=\"8\"",
		9 => "cellpadding=\"9\"",
		10 => "cellpadding=\"10\""
	);

	%cs	= (
		0 => "cellspacing=\"0\"",
		1 => "cellspacing=\"1\"",
		2 => "cellspacing=\"2\"",
		3 => "cellspacing=\"3\"",
		4 => "cellspacing=\"4\"",
		5 => "cellspacing=\"5\"",
		6 => "cellspacing=\"6\"",
		7 => "cellspacing=\"7\"",
		8 => "cellspacing=\"8\"",
		9 => "cellspacing=\"9\"",
		10 => "cellspacing=\"10\""
	);



}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub MakeCSVHtmlTable {
	local($mode,%csv) = @_;
	local($strtmp,$i,$tmp01,$tmp02);

	if($mode eq 1) {
		$strtmp .= "<table border='1'>";
		for($i = 0;$i <= $csv{'MAXRECORD'}; $i++) {
			$tmp01 = join("",MAX,"_",$i);
			$strtmp .= "<tr>";	
			for($j = 0; $j <= $csv{$tmp01}; $j++) {
				$tmp02 = join("",$i,"_",$j);
				$csv{$tmp02} = &ConvHTMLTag($csv{$tmp02});
				$strtmp .= "<td>$csv{$tmp02}</td>";
			}
			$strtmp .= "</tr>";
		}
		$strtmp .= "</table>";
		return $strtmp;
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub MakeSelectionBySectionArray {
	local($mode, $section, $selname) = @_;
	local($i,$tmp01,$strtmp);

	if($mode eq 1) {
		for($i = 0;$i <= 1000; $i++) {
			$tmp01 = join("",$section,"-",$i);
			if($INI{$tmp01} eq "") {
				last;
			}
			$strtmp .= "<option value='$i'>$INI{$tmp01}</option>\n";
		}

		$strtmp	= join("","<select name='$selname'>\n",$strtmp,"</select>\n");

		return $strtmp;
	}

}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub MakeCSVLineFromHash {
	local($mode, $strJ, %hash) = @_;
	local($i,$strtmp,$strHname,$key,$val,$max_i,@strarray);

	$i = 0;
	$max_i = -1;

	while(($key, $val) = each %hash) {
		if($key =~ /$strJ/) {
			$max_i++;
		}
	}


	for($i = 0; $i <= $max_i; $i++) {
		$strHname = join("",$strJ,$i);
		$hash{$strHname} = &ConvCSVString($hash{$strHname});
		print "$strHname = $hash{$strHname}<br>";
		push(@strarray,$hash{$strHname});
	}


	$strtmp = join(",",@strarray);

	return $strtmp;

}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub ConvCSVString {
	local($strtmp) = @_;

	$strtmp =~ s/"/""/g;
	if($strtmp =~ /,/) {
		$strtmp = &SandWitch(1,$strtmp,"\"");
	}

	$strtmp =~ s/\r\n/\n/g;
	$strtmp =~ s/\n/_N_/g;

	#$strtmp =~ s/&/&amp;/g;
	#$strtmp =~ s/"/&quot;/g;
	#$strtmp =~ s/</&lt;/g;
	#$strtmp =~ s/>/&gt;/g;
	#$strtmp =~ s/,/&#44;/g;

	return $strtmp;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub ConvInputString {
	local($strtmp) = @_;

	$strtmp =~ s/_N_/\n/g;

	return $strtmp;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub UpdateINIFile {
	local($mode,$fname,$section,$strFkey,$strCval) = @_;
	local($i,$StrCurSection,$strline,@strarray);
	

	$strline = &ReadFileData($fname, 1);	#設定ファイルの読み込み
	$strline = &JE($strline);
	@strarray = split(/\n/,$strline);		#改行ごとに区切る


	for($i = 0; $i <= $#strarray; $i++) {
		#セクション初期化・及び変更
		if($strarray[$i] =~ /\[.*\]/) {
			#print "Section:$strarray[$i]<br>\n";	#デバグ用
			
			$StrCurSection = $strarray[$i];		#カレントセクション変数の格納する
			$StrCurSection =~ s/(\[|\])//g;		#中括弧をはずす
			next;
		#キーと値のの初期化
		} elsif(($strarray[$i] =~ /^$strFkey/) && ($StrCurSection eq $section)) {
			$strFval = join("",$section,"-",$strFkey);
			$strarray[$i] =~ s/= $INI{$strFval}/= $strCval/g;
		}
	}

	$strline = join("\n",@strarray);
	&jcode'convert(*strline, $INI{'GROBAL-DecodeINITo'});
	&RecordFileData($fname, 3, $strline, @strarray);



}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub GetFileArray {
	local($mode,$path) = @_;
	local($i,$strtmp,@tmparray);

	if($mode eq 1) {
		opendir(DIR,"$path");
		@tmparray = readdir(DIR);
		closedir(DIR);

		return @tmparray;
	} elsif($mode eq 2) {
		opendir(DIR,"$path");
		@tmparray = grep(!/^(\.|\.\.)$/,readdir(DIR));
		closedir(DIR);

		return @tmparray;
	} elsif($mode eq 3) {
		opendir(DIR,"$path");
		@tmparray = grep { (-d "$path$_") && (!/^(\.|\.\.)$/) } readdir(DIR);
		closedir(DIR);

		return @tmparray;
	}
	
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub WebTool_MakeRandomTitleMeta {
	local($mode,$titlefront,$keyfront,$discfront) = @_;
	local($strtmp,$i);

	if(($WebTool_IsFirstTime eq 1) || ($WebTool_IsFirstTime eq "")) {
		$WebTool_Word_Line = &ReadFileData($wordsfile,1);
		@WebTool_Words = split(/\n/,$WebTool_Word_Line);
		$WebTool_IsFirstTime = 0;
	}

	#変数初期化
	$WebTool_Titleback	 = "";
	$WebTool_Keyback	 = "";
	$WebTool_Discback	 = "";

	#ランダムタイトル作成
	$WebTool_Titleback = $WebTool_Words[int(rand($#WebTool_Words))];

	#ランダムキーワード作成
	for($i = 0; $i < 5; $i++) {
		$WebTool_Keyback = join("",$WebTool_Keyback,",",$WebTool_Words[int(rand($#WebTool_Words))]);
	}

	#ランダムディスクリプション作成	
	for($i = 0; $i < 3; $i++) {
		$WebTool_Discback = join("",$WebTool_Discback," ",$WebTool_Words[int(rand($#WebTool_Words))]);
	}

	#返り値作成
	$strtmp = join("","","
<title>$titlefront$WebTool_Titleback</title>
<META name=\"Keywords\" CONTENT=\"$keyfront$WebTool_Keyback\">
<META name=\"Description\" CONTENT=\"$discfront$WebTool_Discback\">
	");

	return "$strtmp";
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub GetDateStringFromComServer {
	local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst,$datestr);
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time + 14*60*60);
	$mon++;
		
	if($sec < 10) {$sec = "0$sec";};
	if($min < 10) {$min = "0$min";};
	if($hour < 10) {$hour = "0$hour";};
	if($year < 99) {$year = $year + 2000}
	else {$year = $year + 1900;};

	$datestr = "$year:$mon:$mday:$hour:$min:$sec";

	return $datestr;
}


# End  2000/8/11

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub Parapara {

	local($color) = @_;

	if($Parapara_i eq "") {
		$Parapara_i = 1;
	}

	if($Parapara_i eq "1") {
		$color = "#FFFFFF";
		$Parapara_i = "0";
	} else {
		$Parapara_i = "1";		
	}

	return $color;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub StringMatchToArray {

	local($strF,@strarray) = @_;
	local($TMP);


	foreach $TMP (@strarray) {
		if(($TMP eq $strF) && ($strF ne "")) {
			return "1";
		}
	}

	return "0";
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub ConvNumMon {
	local($strtmp) = @_;

	if($strtmp eq "Jan") {$strtmp = "1";}
	elsif($strtmp eq "Feb") {$strtmp = "2";}
	elsif($strtmp eq "Mar") {$strtmp = "3";}
	elsif($strtmp eq "Apr") {$strtmp = "4";}
	elsif($strtmp eq "May") {$strtmp = "5";}
	elsif($strtmp eq "Jun") {$strtmp = "6";}
	elsif($strtmp eq "Jul") {$strtmp = "7";}
	elsif($strtmp eq "Aug") {$strtmp = "8";}
	elsif($strtmp eq "Sep") {$strtmp = "9";}
	elsif($strtmp eq "Oct") {$strtmp = "10";}
	elsif($strtmp eq "Nov") {$strtmp = "11";}
	elsif($strtmp eq "Dec") {$strtmp = "12";}

	return $strtmp;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub OpenBinaryFileData {
	local($fname) = @_;
	local($strline);

	open(BD,$fname);
	binmode(BD);
	while(<BD>) {
		$strline = $strline . $_;
	}
	close(BD);

	return $strline;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub RecordBinaryFileData {
	local($fname,$fdata) = @_;

	open(BD,">$fname");
	binmode(BD);
	print BD "$fdata";
	close(BD);

}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub SaveSTDINData {
	open(DB,">Tmp");
	binmode(DB);
	binmode(STDIN);
	while(<STDIN>){
		print DB $_;
	}
	close(DB);
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub InitFromString {

	local($strtmp) = @_;

	($dum,$q) = split(/\?/,$strtmp, 2);
	@qs = split(/&/, $q);
	foreach $tmp (@qs) {
		($k,$v) = split(/=/, $tmp);
		$v =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
		$form{$k} = $v;
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub JJ {
	local($strtmp) = @_;

	&jcode'convert(*strtmp, 'jis');

	return $strtmp;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub FileTransferVer1 {
	#送れるファイルのサイズの制限はここの数字で指定
	return if($ENV{'CONTENT_LENGTH'} > 500000);

	#ファイル名クリア
	$filedata='';
	#ヘッダ獲得
	open(TMP,"Tmp");

	while(<TMP>){
		#動作がきになる人は下のコメントをはずしてみよう
		#print &PH;
		#print "decode0:$_<br>\n";

		#ファイル転送。CR+LFで終了
		last if($_=~/^\r\n/);

		#-----っていうヘッダの後ろについている数字を取り出す。終了判別のため
		$bound = $_ if($_=~/^--/);

		#ヘッダの中から実ファイル名を取り出す
		if ($_=~/filename=/i){
			#効率悪いのは正規表現苦手だから♪　まず”の削除
			$file =$_;
			@filename=split(/\"/,$file);
			foreach $file (@filename) {
				if ($file =~/\./){$filedata =$file;}
			}
			#効率悪いのは正規表現苦手だから♪　￥の削除。ファイル名の判別は.で行う
			$file ="test\\$filedata\\test";
			@filename=split(/\\/,$file);
			foreach $file (@filename) {
				if ($file =~/\./){$filedata =$file;}
			}
		}
	}

	#ファイルの転送を行うの
	if ($filedata ne ''){
		#print "$filedataの転送：";
		$bound=~s/\r\n//;
		open(DATA,">$datdir$filedata") || print "オープン失敗<br>\n";
		while(<TMP>){
			last if($_=~/^$bound/);
			print DATA $_;
		}
		#print "終了";
		close (DATA);
		#print "<br>\n";
	}else{
		#print "ファイル名をちゃんと入れてね<br>\n";
		print &PH;
		print &WmErrMsg("アップロードエラー","<h3>ファイル名を入力して下さい</h3>");
		exit(0);
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub GetMaxNumberFromINIHash {
	local($mode, $section, %hash) = @_;
	local($i,$tmp01,$strtmp);


	if($mode eq 1) {
		for($i = 1;$i <= 1000; $i++) {
			$tmp01 = join("",$section,"-",$i);
			if($hash{$tmp01} eq "") {
				$strtmp = $i - 1;
				last;
			}
		}

		return $strtmp;
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub GetArrayFromINIHash {
	local($mode, $section, %hash) = @_;
	local($i,$tmp01,$strtmp,@tmparray);

	if($mode eq 1) {
		for($i = 1;$i <= 1000; $i++) {
			$tmp01 = join("",$section,"-",$i);
			if($hash{$tmp01} eq "") {
				last;
			} else {
				push(@tmparray,$hash{$tmp01});
			}
		}

		return @tmparray;
	}

}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub FunnySQL {
	local($mode,$fname,$lsp,$dsp,$id,$idx) = @_;
	local($i,$strtmp,$fdata,@flines,@dlines,@strarray);


	if($mode eq "1") {
		if($fname eq "") {
			$fdata = $CurFileData;
		} else {
			$fdata = &ReadFileData($fname,1);
		}

		@flines = split(/$lsp/,$fdata);

		for($i = 0; $i <= $#flines; $i++) {
			@dlines = split(/$dsp/,$flines[$i]);
			if($dlines[0] eq $id) {
				$strtmp = $dlines[$idx];
				last;
			}
		}

		return $strtmp;
	}
	elsif($mode eq "2") {
		if($fname eq "") {
			$fdata = $CurFileData;
		} else {
			$fdata = &ReadFileData($fname,1);
		}

		@flines = split(/$lsp/,$fdata);

		for($i = 0; $i <= $#flines; $i++) {
			@dlines = split(/$dsp/,$flines[$i]);
			push(@strarray,$dlines[$idx]);
		}

		return @strarray;
	}


}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub ConvPrice {
	local($strtmp) = @_;



	$strtmp =~ s/１/1/g;
	$strtmp =~ s/２/2/g;
	$strtmp =~ s/３/3/g;
	$strtmp =~ s/４/4/g;
	$strtmp =~ s/５/5/g;
	$strtmp =~ s/６/6/g;
	$strtmp =~ s/７/7/g;
	$strtmp =~ s/８/8/g;
	$strtmp =~ s/９/9/g;
	$strtmp =~ s/０/0/g;

	$strtmp =~ s/\D//g;	

	if($strtmp eq "") {
		$strtmp = "0";
	}


	return $strtmp;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub MakeHiddenValueWithFilter {
	local($remove, %hash,) = @_;
	local($strtmp, $key, $value, $tmp, $rem_flag, @removes);


	@removes = split(/:/, $remove);

	while(($key, $value) = each %hash) {

		$rem_flag = 0;

		foreach $tmp (@removes) {
			if($tmp eq $key) {
				$rem_flag = 1;
				next;
			}
		}

		if($rem_flag ne 1) {
			$strtmp = $strtmp . "<input type=\"hidden\" name=\"$key\" value=\"$value\">\n";
		}
	}


	return $strtmp;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub StopWatchVer1 {

	local($flag) = @_;
	local($strtmp);

	if($flag eq "start") {
		$SW_START = time;
	} elsif($flag eq "stop") {
		$SW_STOP = time;
		$strtmp = $SW_STOP - $SW_START;
		return $strtmp;
	}
	
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub StockFileData {
	local($fname) = @_;

	$CurFileData = &ReadFileData($fname,1);
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub ListArray {
	local($mode,@strarray) = @_;
	local($strtmp);

	if($mode eq "1") {
		foreach $strtmp (@strarray) {
			print "$strtmp<br>\n";
		}
	}
}


#フォルダ及びファイル存在確認->なければ作る

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub CheckAndMakeFile {
	local($fpath,$fperm) = @_;

	if(-e $fpath) {
		return "1";
	} else {
		#なければ作る
		mkdir($fpath,$fperm);
		return "0";
	}
}


#アカウント文字列作成-----------------------------

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub MakeAccountStr {

	local($Id,$Pwd,$sp) = @_;
	local($strline,@strarray);


	$Pwd = crypt($Pwd,substr($Pwd,0,2));

	$Id = &ConvCSVString($Id);
	$Pwd = &ConvCSVString($Pwd);
	$strline = join($sp,$Id,$Pwd);

	$strline = crypt($strline,substr($strline,0,2));

	$strline = &ReverseString($strline);

	return $strline;

}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub ReverseString {
	local($strtmp) = @_;
	local(@strarray);

	@strarray = split(//,$strtmp);
	@strarray = reverse(@strarray);
	$strtmp = join("",@strarray);

	return $strtmp;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub ConvVal{
	local($strtmp) = @_;
		$strtmp =~ s/_(txt\w+)_/${"$1$lng"}/g;
		$strtmp =~ s/_(\w+)_/${$1}/g;
	return $strtmp;
}

# End 2000/11/29

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub URLEncode {
	local($strtmp) = @_;
	$strtmp =~ s/(\W)/'%'.unpack("H2", $1)/ego;
	return $strtmp;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub URLDecode {
	local($strtmp) = @_;
	$strtmp =~ s/%([0-9a-f][0-9a-f])/pack("C",hex($1))/egi;
	return $strtmp;
}



#----------------

# End 2000/12/13

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub ListHash {
	local($mode,%hash) = @_;
	local(@strarray);

	if($mode eq "1") {
		while(($k,$v) = each %hash) {
			push(@strarray,"$k=$v");
		}

		return @strarray;
	}

}


# End 2000/12/14

########################################
#	クッキーを取得する
########################################

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub GetCookie {
	local($strtmp,$c,$p,$n,$v,$vn,$vv,@p,@parray);
	$c = $ENV{'HTTP_COOKIE'};
	@parray = split(/;/,$c);
	foreach $p (@parray) {
		($n,$v) = split(/=/,$p);
		$n =~ s/ //g;
		@varray = split(/,/,$v);
		foreach $v (@varray) {
			($vn,$vv) = split(/:/,$v);
			$strtmp = $n . "x" . $vn;
			${$strtmp} = $COOKIE{"$n\-$vn"} = $vv;
		}
	}
}

########################################
#	クッキーを埋め込む
########################################

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub PutCookie {

	local($c_name,$c_value,$c_time) = @_;

	($c_sec,$c_min,$c_hour,$c_mday,$c_mon,$c_year,$c_wday,$c_yday,$c_isdst) = localtime(time + $c_time * 60 * 60);

	$c_year = $c_year + 1900; #重要！ これで c_year は "2000" になる
	if ($c_year < 10)  { $c_year = "0$c_year"; }
	if ($c_sec < 10)   { $c_sec  = "0$c_sec";  }
	if ($c_min < 10)   { $c_min  = "0$c_min";  }
	if ($c_hour < 10)  { $c_hour = "0$c_hour"; }
	if ($c_mday < 10)  { $c_mday = "0$c_mday"; }

	#曜日配列作成
	@day = qw(		Sun		Mon		Tue		Wed		Thu		Fri		Sat	);
	#月配列作成
	@month = qw(		Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec	);

	#曜日設定
	$c_day = @day[$c_wday];
	#月設定
	$c_month = @month[$c_mon];

	#期限文字列作成
	$c_expires = "$c_day, $c_mday\-$c_month\-$c_year $c_hour:$c_min:$c_sec GMT";

	#値を返す
	return "Set-Cookie: $c_name=$c_value; expires=$c_expires\n";
}

########################################
#	指定の秒数から日付を取得する
########################################

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub GetSpecDateString {
	local($time,$key) = @_;
	local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst,$datestr);

	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
	$mon++;

	if($sec < 10) {$sec = "0$sec";};
	if($min < 10) {$min = "0$min";};
	if($hour < 10) {$hour = "0$hour";};
	if($mday < 10) {$mday = "0$mday";};
	if($mon < 10) {$mon = "0$mon";};
	if($year < 99) {$year = $year + 2000}
	else {$year = $year + 1900;};

	$datestr = "$year:$mon:$mday:$hour:$min:$sec";

	if($key eq "") {
		return $datestr;
	} else {
		return ${$key};
	}
}

########################################
#	ファイル情報を取得する
########################################

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub GetSpecFileInfo {
	local($fpath,$key) = @_;
	local($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks);

	($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($fpath);

	return ${$key};
}


########################################
#	配列から Select を作成する
########################################

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub MakeSelectionByStrArray {
	local($mode, $selname, @strarray,@strarray02) = @_;
	local($i,$tmp01,$strtmp);



	if($mode eq 1) {
		for($i = 0;$i <= $#strarray; $i++) {
			if($pselected eq $i) {
				$selected = "selected";
			} else {
				$selected = "";
			}

			$strtmp .= "<option value='$i' $selected>$strarray[$i]</option>\n";
		}

		$strtmp	= join("","<select name='$selname'>\n",$strtmp,"</select>\n");

		return $strtmp;
	}
	elsif($mode eq 2) {

		local($mode, $selname, *strarray,*strarray02) = @_;

		for($i = 0;$i <= $#strarray; $i++) {

			if($pselected eq $strarray[$i]) {
				$selected = "selected";
			} else {
				$selected = "";
			}

			$strtmp .= "<option value='$strarray[$i]' $selected>$strarray02[$i]</option>\n";
		}

		$strtmp	= join("","<select name='$selname'>\n",$strtmp,"</select>\n");

		return $strtmp;
	}

}

########################################
#	配列から Hash を作成する
########################################

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub MakeHashFromStrArray {
	local(@strarray) = @_;
	local($i,$k,$v,%hash);


	for($i = 0; $i <= $#strarray; $i++) {
		($k,$v) = split(/=/,$strarray[$i]);
		$hash{$k} = $v;
	}

	return %hash;
}


#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub MakeDateSelection {
	local($mode,$date,$sname) = @_;
	local($y_i,$m_i,$d_i,$y_max,$m_max,$d_max);

	$cur_y = &GetSpecDateString($date,"year");
	$cur_m = &GetSpecDateString($date,"mon");
	$cur_d = &GetSpecDateString($date,"mday");

	$y_max = $cur_y + 1;
	$m_max = 12;
	$d_max = 31;

	if($pselecteddate eq "") {
		$selecteddate = "$cur_y$cur_m$cur_d";
	} else {
		$selecteddate = "$pselecteddate";
	}

	if($mode eq 1) {
		for($y_i = $cur_y; $y_i <= $y_max; $y_i++) {
			for($m_i = 1; $m_i <= $m_max; $m_i++) {
				for($d_i = 1; $d_i <= $d_max; $d_i++) {

					$py = sprintf("%04d",$y_i);
					$pm = sprintf("%02d",$m_i);
					$pd = sprintf("%02d",$d_i);

					if($selecteddate eq "$py$pm$pd") {
						$selected = " selected";
					} else {
						$selected = "";
					}

					$pdate = join("/",$py,$pm,$pd);
					$strtmp .= "<option value=\"$pdate\"$selected>$pdate</option>\n";
				}
			}
		}

		$strtmp = "<select name=\"$sname\"> $strtmp </select>";

		return $strtmp;
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub ImportHash {
	local(*hash) = @_;
	local($k,$v);

	while(($k,$v) = each %hash) {
		#デバグ用
		#print "$k = $v<br>\n";
		${$k} = $v;
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub ExportHash {
	local(*hash) = @_;
	local($k,$v);


	#print &PH;

	while(($k,$v) = each %hash) {
		#デバグ用
		#print "$k = $v<br>\n";
		$hash{$k} = $v;
		#print "$k<BR>";
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub CheckFileDateAndDelete {
	local($mode,$fpath,$v) = @_;
	local($ctime,$ftime);

	#エラー処理
	if(!(-e $fpath)) {
		return "0";
	}

	if($mode eq "hour") {
		#デバグ用
		#print &PH;
		#print &GetSpecDateString(time + $v * 60 * 60); 
		#print "<br>";

		$ctime = time;
		$ftime = &GetSpecFileInfo($fpath,"mtime");

		$ltime = $ctime - $ftime;

		#print &GetSpecDateString($ftime) . "<br>";
		#print &GetSpecDateString($ctime) . "<br>";
		#print $v * 60 * 60 . "<br>";

		if($ltime < $v * 60 * 60) {
			return "0";
		} else {
			unlink $fpath;
			return "1";
		}
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub MakeTempLabel {
	local($strtmp) = @_;

	$strtmp = "<br> <br> <center> $f4<b>$strtmp</b>$fc </center>";

	return $strtmp;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub SortInOne {
	local(@strArray) = @_;
	local(@tmpArray,$flag,$i,$pcnt,$j);

	$flag = 0;
	# $pcnt = 0;

		for($i = 0; $i <= $#strArray; $i++) {
			$flag = 0;	
			if(@tmpArray eq "") {
				$tmpArray[0] = $strArray[$i];
			} else {
				for($j = 0; $j <= $#tmpArray; $j++) {
					if($strArray[$i] eq $tmpArray[$j]) {
						$flag = 1;
					break;
					}
				}

				if($flag eq 0) {
					$tmpArray[$#tmpArray + 1] = $strArray[$i];
				}
			}
		}

	return @tmpArray;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub KstdSendMail {
	local($mode,$mailprog,$from,$to,$subject,$content) = @_;

	if($mode eq 1) {

		#&RecordFileData("tmp",3,$content);
		#open(FILE, "<:utf8", "tmp");
		#$dd = "";
		#while (read(FILE, $buf, 60*57)) {
		#	$dd .= encode_base64($buf);
		#}
		#$content = $dd;

		if(open(MAIL,"| $mailprog $to")) {

			$subject = '=?UTF-8?B?' . encode_base64($subject,'') . '?=';

			print MAIL "Return-Path: $from\n";
			print MAIL "To: $to\n";
			print MAIL "From: $from\n";
			print MAIL "Subject: $subject\n";
			print MAIL "Content-Type: text/plain; charset=\"UTF-8\"\n";
			print MAIL "Content-Transfer-Encoding: 8bit\n\n";
			#print MAIL "Content-Transfer-Encoding: base64\n\n";

			#print MAIL &bodyencode($content);
			#print MAIL encode_base64($content);
			print MAIL $content;

			print MAIL "\n\n";

			close(MAIL);
		} else {
			#送信エラー
		}
	}
	#添付ファイル付き -------------
	elsif($mode eq 2) {

		$bdry = int(rand(10000000));

		open(SEND,"|$mailprog $to");
		#FROM
		$return_path = $from;
		$from = "From: $from";
		$from=&mimeencode($from);
		#SUBJECT
		$subject="Subject: $subject";
		$subject=&mimeencode($subject);
		#MSG
		$msg = $content;
		&jcode'convert(*msg,'jis');


		## ヘッダー出力部分 ------------------------
		print MAIL "Return-Path: $return_path\n";
		print SEND "$from\n";
		print SEND 'MIME-Version: 1.0',"\n";
		print SEND "To: $form{'to'}\n";

		#if($form{'cc'} ne ""){
		#	$cc =&mimeencode($form{'cc'});
		#	print SEND "Cc: $cc\n";
		#}
		#if($form{'bcc'} ne ""){
		#	$bcc =&mimeencode($form{'bcc'});
		#	print SEND "Bcc: $bcc\n";
		#}

		print SEND "$subject\n";
		print SEND 'Content-Transfer-Encoding: 7bit'."\n";
		print SEND "Content-Type: multipart/mixed; boundary=\"$bdry\"\n";
		print SEND "\n\n";


		## ボディー出力部分 -----------------------

		print SEND "--$bdry\n";
		print SEND 'Content-Type: text/plain; charset=ISO-2022-JP'."\n";
		print SEND "\n";
		print SEND "$msg\n";
		print SEND "\n";

		## 添付出力部分 -----------------------

		$attach_name = $form{'attach1'};
		$attach_type = &DetectFileType($form{'attach1'});
		$attach_dat = &EncodeBase64a($form{'attach_dat1'});

		print SEND "--$bdry\n";
		print SEND "Content-Type: $attach_type".'; '."name=\"$attach_name\"\n";
		print SEND 'Content-Disposition: attachment;'."\n";
	 	print SEND " filename=\"$attach_name\"\n";
	 	print SEND 'Content-Transfer-Encoding: base64'."\n";
		print SEND "\n";
		print SEND "$attach_dat";
		print SEND "\n";
		print SEND "--$bdry--\n";
		close SEND;
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub KstdNETxSMTP {
	local($mode,$smtpsrv,$from,$to,$subject,$content) = @_;

	if($smtpsrv =~ /(net|com|org)/) {
		($host,$domain) = $smtpsrv =~ /(.*?)\.(.*)/;
	} elsif($smtpsrv =~ /(ne\.jp|co\.jp|or\.jp)/) {
		($host,$domain) = $smtpsrv =~ /(.*?)\.(.*)/;
	}


	if($mode eq 1) {

		$smtp = Net::SMTP->new($smtpsrv,Hello=>$domain) or die "X $host,$domain";

		$smtp->mail($from);
		$smtp->to($to);

		$content = &JJ($content);

		$smtp->data();
		$smtp->datasend("From:$from\n");
		$smtp->datasend("To:$to\n");
		$smtp->datasend("Subject:$subject\n");
		$smtp->datasend("Content-Type: text/plain; charset=ISO-2022-JP\n");
		$smtp->datasend("\n");
		$smtp->datasend("$content\n");

		$smtp->dataend();
		$smtp->quit;
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub CheckIsNULLInHashWithFilter {
	local(*remove,*hash) = @_;
	local($k,$v);

	while(($k,$v) = each %hash) {
		if(&StringMatchToArray($k,@remove) ne 1) {
			if($v eq "") {
				$pNULL = $k;
				return 1;
			}
		}
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub ConvPriceComma {
    local($_) = @_;
    1 while s/(.*\d)(\d\d\d)/$1,$2/;
    $_;
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub MakeHashFromString {

	local($mode,$strtmp,$sp,$sp2,$hn) = @_;
	local($q,$tmp,$k,$v,@qs,%hash);
	
	if($mode eq 1) {
		@qs = split(/$sp/, $strtmp);
		foreach $tmp (@qs) {
			($k,$v) = split(/$sp2/, $tmp);
			$v =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
			$hash{$k} = $v;
		}

		return %hash;

	} elsif($mode eq 2) {

		@qs = split(/$sp/, $strtmp);
		foreach $tmp (@qs) {
			($k,$v) = split(/$sp2/, $tmp);
			$v =~ s/%([A-Fa-f0-9][A-Fa-f0-9])/pack("C", hex($1))/eg;
			$tmp = $hn . "x" . $k;
			$v =~ s/_N_/\n/g;

			${$tmp} = $v;
		}	
	}

}

#　@(f)
#
#　機能　	：	四捨五入する
#
#　引数　	：	$num ---	数字
#			$decimals ---	四捨五入する桁
#
#　返り値	：	数字
#
#　機能説明　	：	
#
#　備考　	：	借り物

sub Round {
  local($num, $decimals) = @_;
  local($format, $magic);
  $format = '%.' . $decimals . 'f';
  $magic = ($num > 0) ? 0.5 : -0.5;
  sprintf($format, int(($num * (10 ** $decimals)) + $magic) /
                   (10 ** $decimals));
}

#　@(f)
#
#　機能　	：	日付フォーマットを所得する
#
#　引数　	：	$strtmp ---	：つき時間
#
#　返り値	：	YYYY/MM/DD文字列
#
#　機能説明　	：	
#
#　備考　	：	

sub GetDltDateString {
	local($strtmp);

	$strtmp = &GetDateString;
	$strtmp =~ s/:/\//g;
	($strtmp,$dum) = $strtmp =~ /(..........)(......)/;

	return $strtmp;

}

#　@(f)
#
#　機能　	：	○Ｘ判定
#
#　引数　	：	１か０
#
#　返り値	：	○、Ｘ
#
#　機能説明　	：	
#
#　備考　	：	

sub MaruBatu {
	local($q) = @_;

	if($q) {
		return "○";
	} else {
		return "×";
	}
}

#　@(f)
#
#　機能　	：	１と０を交換する
#
#　引数　	：	１か０
#
#　返り値	：	１か０
#
#　機能説明　	：	
#
#　備考　	：	

sub IchiZero {
	local($q) = @_;

	if($q) {
		return "0";
	} else {
		return "1";
	}
}

#　@(f)
#
#　機能　	：	
#
#　引数　	：	
#
#　返り値	：	
#
#　機能説明　	：	
#
#　備考　	：	

sub IsAlcoholic {
	local($gid) = @_;

	&ExecSQL("SELECT CatID from $INI{'GROBAL-GcDBName'} WHERE GoodsID = \'$gid\'");
	$form{'catkey'} = &GetValueFromSTH(1,"CatID");


	if(($form{'catkey'} eq "c007c001") || ($form{'catkey'} eq "c007c002")) {
		return 1;
	} else {
		return 0;
	}
}

#　@(f)
#
#　機能　	：	配列を混ぜる
#
#　引数　	：	@old ---	配列
#
#　返り値	：	配列
#
#　機能説明　	：	
#
#　備考　	：	

sub SuffleArray {
	local(@old) = @_;
	local(@new);


	while (@old) {
		push(@new, splice(@old, int(rand() * $#old), 1));
	}

	return @new;

}

#　@(f)
#
#　機能　	：	ファイルタイプ判別
#
#　引数　	：	$strtmp ---	ファイル名＋拡張子
#
#　返り値	：	拡張子文字列
#
#　機能説明　	：	
#
#　備考　	：	

sub DetectFileType {
	local($strtmp) = @_;
	local($fname,$fext);

	($fname,$fext) = split(/./,$strtmp);

	if($fext eq 'gif'){
		$strline = 'image/gif';
	}
	elsif(($fext eq 'jpeg') or ($f_type eq 'jpg')){
		$strline = 'image/jpeg';
	}
	elsif($fext eq 'bmp'){
		$strline = 'image/bmp';
	}
	else{
		$strline = 'application/octet-stream';
	}

	return $strline;
}



###


sub StopWatchVer1 {


	local($flag) = @_;
	local($strtmp);


	if($flag eq "start") {
		$SW_START = time;
	} elsif($flag eq "stop") {
		$SW_STOP = time;
		$strtmp = $SW_STOP - $SW_START;
		return $strtmp;
	}
	
}

#--------------------------------------------------------------------------
# ＣＳＶ文字列を一般文字列にして配列にして返す
#--------------------------------------------------------------------------

sub ConvCSVtoNormal {
	local($strtmp) = @_;
	local($k,$j,$InValFlag,@strarray,@chararray,@valarray);

	$InValFlag = 0;

	$strtmp =~ s/;.*//g;
	$strtmp =~ s/""/_DBLAP_/g;
	@chararray = split("",$strtmp);



	for($j = 0; $j <= $#chararray; $j++) {
		if($chararray[$j] eq "\"") {
			if($InValFlag eq 0) {
				$InValFlag = 1;
			} elsif($InValFlag eq 1) {
				$InValFlag = 0;
			}
			next;
		} else {
			if($chararray[$j] eq ",") {
				#区切りカンマの場合
				if($InValFlag eq 0) {
				#値カンマの場合
				} elsif($InValFlag eq 1) {
					$chararray[$j] =~ s/$chararray[$j]/_VALKAM_/g;
				}
			}
		}
	}
	$strtmp = join("",@chararray);
	$strtmp =~ s/"//g;


	#print "<br> ato $strtmp<br>";

	@valarray = split(/,/,$strtmp);
	for($k = 0;$k <= $#valarray; $k++) {
		$valarray[$k] =~ s/_DBLAP_/"/g;
		$valarray[$k] =~ s/_VALKAM_/,/g;
		$strarray[$k] = $valarray[$k];
		#print $strarray[$k] . ":";
	}


	#print "\n<br>test " . @strarray;

	return @strarray;
}

#設定ファイル更新---------------------------------
# モード、ファイル名、セクション、キー、キーの値、更新する値
sub WmUpdateINIFile {
	local($mode,$fname,$section,$strFkey,$strFval,$strCval) = @_;
	local($i,$StrCurSection,$strline,@strarray);
	

	$strline = &ReadFileData($fname, 1);	#設定ファイルの読み込み
	$strline = &JE($strline);


	$strline =~ s/\r//g;
	@strarray = split(/\n/,$strline);		#改行ごとに区切る


	for($i = 0; $i <= $#strarray; $i++) {
		#サーバー側ＰＥＲＬエンジンデバグ用 --- ここから
		#if($SrvCantUseN eq "1") {
		#	if($#strarray ne $i) {
		#		chop($strarray[$i]);		#改行をはずす
		#	}
		#}
		#chomp($strarray[$i]);

		#$strarray[$i] =~ s/\r/ZZZ/g;
		#print "XXX $strarray[$i] ___";
		#$strarray[$i] =~ s/ZZZ/\r/g;
		#next;

		#セクション初期化・及び変更
		if($strarray[$i] =~ /\[.*\]/) {
			#print "Section:$strarray[$i]<br>\n";	#デバグ用
			
			$StrCurSection = $strarray[$i];		#カレントセクション変数の格納する
			$StrCurSection =~ s/(\[|\])//g;		#中括弧をはずす
			next;

		#キーと値のの初期化
		} elsif(($strarray[$i] =~ /^$strFkey/) && ($StrCurSection eq $section)) {
			#$strFval = join("",$section,"-",$strFkey);
			$strarray[$i] =~ s/= $strFval/= $strCval/g;
		}
	}

	$strline = join("\n",@strarray);
	&jcode'convert(*strline, $INI{'GROBAL-DecodeINITo'});
	&RecordFileData($fname, 3, $strline, @strarray);

}

sub MakeStringFromHash {

	local($mode,$odj,$odj2,*hash) = @_;
	local($k,$v,@strarray);

	if($mode eq 1) {
		while(($k,$v) = each %hash) {
			$v =~ s/\r//g;
			$v =~ s/\n/_N_/g;
			#空ならばファイルに保存しない（デバグ）
			if($v ne "") {
				push(@strarray,"$k$odj2$v");
			}
		}

		return join($odj,@strarray);
	}

}


1;
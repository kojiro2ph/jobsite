
use Image::Magick;

sub tp {

	#変数定義 ---
	$pathtp = "tp/";
	$pathtp_s = "tp/s/";

	#今日の写真アップロード ---
	if($form{'upload'} eq "1") {

		#バックアップ(アルバムにずらす ---
		#&ResizeGdsImg("$pathtp" . "tp.jpg","$pathtp" . "tp_" . time . ".jpg",640,0);

		if($formdata{"tp_fname"} =~ /\.jpg/i) { 

			$tim = time;

			#新しいファイルをtp.jpgとして保存 ---
			&RecordBinaryFileData("$pathtp" . "tp_$tim.jpg",$formdata{"tp_fdata"});
			#リサイズ ---
			&ResizeGdsImg("$pathtp" . "tp_$tim.jpg","$pathtp" . "tp_$tim.jpg",640,480);

			#写真情報に追加 ---
			$q = join("","
				INSERT INTO hbjms_tptb 
					(tpid,tpeid,tpjid,tpregdt,tptim,tpflg) VALUES
					('tp_$tim.jpg','$eid','$ejid',NOW(),'$tim','1')
			");
			&ExecSQL($q);

		} else {

		}

	}
	#写真の削除 ---
	if($form{'dltp'} ne "") {
		#unlink "$pathtp" . $form{'dltp'};
		$q = "UPDATE hbjms_tptb SET tpflg = '0' WHERE tpid = '$form{'dltp'}'";
		&ExecSQL($q);
	}
	#コメントの登録 ---
	if($form{'say'} eq "1") {
		if($form{'comment'} ne "") {
			$tptim = time;
			$q = join("","
				INSERT INTO hbjms_tpcommenttb 
					(tpid,tpeid,tpcomment,tpregdt,tptim,tpflg) VALUES
					('$form{'tp'}','$eid','$form{'comment'}',NOW(),'$tptim','1')
			");
			&ExecSQL($q);
		}
	}

	#コメントの削除 ---
	if($form{'delcomment'} ne "") {
		$q = "UPDATE hbjms_tpcommenttb SET tpflg = '0' WHERE tpid = '$form{'tp'}' AND tptim = '$form{'delcomment'}'";
		&ExecSQL($q);
	}

	#この写真は私がアップロードしました処理 ---
	if($form{'iup'} eq "1") {

		#２重防止 ---
		$q = "SELECT COUNT(tpid) AS cnt FROM hbjms_tptb WHERE tpid = '$form{'tp'}' AND tpeid = '$eid' AND tpflg = '1'";
		&ExecSQL($q);
		$cnt = &GetValueFromSTH(1,"cnt");

		#重複していなければ処理 ---
		if($cnt eq 0) {

			$tptim = time;

			$q = join("","
				INSERT INTO hbjms_tptb 
					(tpid,tpeid,tpjid,tpregdt,tptim,tpflg) VALUES
					('$form{'tp'}','$eid','$ejid',NOW(),'$tptim','1')
			");

			&ExecSQL($q);
		}
	}

	#写真情報変更処理 ---
	if($form{'changetpinfo'} eq "2") {
		$q = "UPDATE hbjms_tptb SET tpeid = '$form{'tpeid'}',tpjid = '$form{'tpjid'}',tpfolid = '$form{'tpfolid'}' WHERE tpid = '$form{'tp'}'";
		&ExecSQL($q);
		$form{'changetpinfo'} = "";
	}

	#フィルタリング情報保存 ---
	if($form{'stpbyjid'} ne "") {
		$q = "UPDATE hbjms_cidmanagetb SET estpbyjid = '$form{'stpbyjid'}',estpbyfolid = '' WHERE cid = '$cid'";
		&ExecSQL($q);
		$estpbyjid = $form{'stpbyjid'};
	}
	if($form{'stpbyfolid'} ne "") {
		$q = "UPDATE hbjms_cidmanagetb SET estpbyfolid = '$form{'stpbyfolid'}' WHERE cid = '$cid'";
		&ExecSQL($q);
		$estpbyfolid = $form{'stpbyfolid'};
	}


	#アルバム作成 ---
	opendir(DIR,"$pathtp");
	@tmparray = grep { /tp_\d+\.jpg/ } readdir(DIR);
	@tmparray = sort(@tmparray);
	closedir(DIR);
	$j = -1;
	for($i = 0; $i <= $#tmparray; $i++) {
		#($dum,$ptim) = $tmparray[$i] =~ /(tp_)(\d+)\.jpg/;
		#$pm = &GetSpecDateString($ptim,"mon");
		#$pd = &GetSpecDateString($ptim,"mday");

		#写真のフィルタリング（重要） ---
		if($estpbyjid eq "") { $estpbyjid = "all"; }
		if($estpbyfolid eq "") { $estpbyfolid = "all"; }

		#ジョブサイトを選択している場合 ---
		if($estpbyjid ne "all") {
			if($#stpbyjid eq -1) {
				@qfld = qw(stpbyjid);
				$q = "SELECT tpid AS stpbyjid FROM hbjms_tptb WHERE tpjid = '$estpbyjid' AND tpflg = '1'";
				&ExecSQL($q);
				&SetFieldToArray(@qfld);
			}
			if($#stpbyfolid eq -1) {
				@qfld = qw(stpbyfolid);
				$q = "SELECT tpid AS stpbyfolid FROM hbjms_tptb WHERE tpfolid = '$estpbyfolid' AND tpflg = '1'";
				&ExecSQL($q);
				&SetFieldToArray(@qfld);
			}

			#ジョブサイトの条件に入った ---
			if(&StringMatchToArray($tmparray[$i],@stpbyjid) eq "1") {

				#フォルダを選択している場合 ---
				if($estpbyfolid ne "all") {

					#フォルダの条件に入った ---
					if(&StringMatchToArray($tmparray[$i],@stpbyfolid) eq "1") {

						&MarkColorForTP;

					#条件にあてはまらない写真は飛ばす ---
					} else {
						next;
					}

				#フォルダをを [ALL] と選択している場合 ---
				} else {

					&MarkColorForTP;

				}

			#条件にあてはまらない写真は飛ばす ---
			} else {
				next;
			}

		#ジョブサイトを [ALL] と選択している場合 ---
		} else {

			&MarkColorForTP;

		}

		$j++;

		#最後の写真としてセット (仮 位置) ---
		$ltp = $tmparray[$i];

		#表示スピードの最適化にサムネイル用の画像を作成 ---
		if(!-e "$pathtp_s$tmparray[$i]") {
			
			#リサイズ ---
			&ResizeGdsImg("$pathtp$tmparray[$i]","$pathtp_s$tmparray[$i]",100,120);

		}

		$albumhtml .= "<td><a href='$ThisFile?act=tp\&tp=$tmparray[$i]'><img src='/jobsite/$pathtp_s$tmparray[$i]' $imgbd></a></td>";

		if(($j+1)%4 eq 0 and $j ne 0) {
			$albumhtml .= "</tr><tr>";
		}
	}

	#フィルタリングエリア作成 --- ここから

	# jobsite selection ---
	$qWHERE = "WHERE jflg = '1'";
	if($estpbyjid ne "") {
		$pselected = $estpbyjid;
	}
	$selstpby = &MakeSelFromTable("1","hbjms_jtb","stpbyjid","jid","jname");
	$selstpby =~ s/<select name='stpbyjid'>/<select name='stpbyjid' onChange="StpBy(this.options[this.options.selectedIndex].value);" style='font-size:14pt; font-weight: bold; background-color: #FFFF66;'><option value='all'>ALL<\/option>/g;

	# folder selection ---
	$qWHERE = "WHERE foltype = 'tp' AND foljid = '$estpbyjid' AND folflg = '1'";
	if($estpbyfolid ne "") {
		$pselected = $estpbyfolid;
	}
	$selfol = &MakeSelFromTable("1","hbjms_foltb","stpbyfolid","folid","foln");
	$selfol =~ s/<select name='stpbyfolid'>/<select name='stpbyfolid' onChange="StpByFolID(this.options[this.options.selectedIndex].value);" style='font-size:14pt; font-weight: bold; background-color: #FFFF66;'><option value='all'>ALL<\/option>/g;


	#フィルタリングエリア作成 --- ここまで

	#アルバムエリア作成 ---
	$albumhtml = join("","
		<font style='font-size: 25pt; font-weight: bold;'>_txttp004_</font>
		\&nbsp;\&nbsp;\&nbsp;
		<font style='font-size: 15pt;'><a href='$ThisFile?act=setj\&step=fol\&foltype=tp\&jid=$estpbyjid'>[ _txttp009_ ]</a></font>

		<br>

		<table border='0'>
		<tr><td>_txtmantbjtba002_ :</td><td>$selstpby</td></tr>
		<tr><td>_txttp008_ :</td><td>$selfol</td></tr>
		</table>

		<table><tr>$albumhtml</tr></table>
	");

	#トップ写真指定 ---
	if($form{'tp'} eq "") {
		$tp = $ltp;
	} else {
		$tp = $form{'tp'};
	}
	#削除オプション ---
	&ExecSQL("SELECT tpeid FROM hbjms_tptb WHERE tpid = '$tp'");
	$strtpeid = &GetValueFromSTH(1,"tpeid");

	if(($eid eq "kojiro2ph\@yahoo.co.jp" or $eid eq $strtpeid) and $tp ne "") {
		$dellink = "<br><a href='$ThisFile?act=tp\&dltp=$tp'>_txttp003_</a><br>";
	}

	#発言エリア　作成 ---
	$commenthtml = join("","
		<td>
		<form name='FrmHBcomment' action='$ThisFile' method='post'>
		<input type='text' name='comment' size='26' style='font-size: 16pt; font-weight: bold;'>
		<input type='submit' value='_txttp006_' style='font-size: 16pt;'>
		<input type='hidden' name='act' value='tp'>
		<input type='hidden' name='say' value='1'>
		<input type='hidden' name='tp' value='$tp'>
		</form>
		</td>
		");
	$commenthtml = "<font style='font-size: 25pt; font-weight: bold;'>_txttp005_</font><table><tr>$commenthtml</tr></table>";

	#コメント一覧　作成 ---
	@qfld = qw(tpid tpeid tpcomment tptim);
	&ExecSQL("SELECT tpid,tpeid,tpcomment,tptim FROM hbjms_tpcommenttb WHERE tpflg = '1' AND tpid = '$tp' ORDER BY tpregdt");
	&SetFieldToArray(@qfld);

	for($i = 0; $i <= $#tpid; $i++) {
		$delcomment = "";
		if($tpeid[$i] eq $eid or $eid eq "kojiro2ph\@yahoo.co.jp") {
			$delcomment = "<font style='font-size: 10pt;'>( <a href='$ThisFile?act=tp\&tp=$tp\&delcomment=$tptim[$i]'>_txttp003_</a> )</font>";
		}

		#翻訳する ---
		#$grs = get("http://ajax.googleapis.com/ajax/services/language/translate?v=1.0\&q=$tpcomment[$i]\&langpair=en\|zh-TW");
		#($tpcomment) = $grs =~ /\"translatedText\"\:\"(.*?)\"/;
		#$tpcomment = decode('utf8',$tpcomment);

		$tpcomment = &TT(1,"",$tpcomment[$i]);

		$comment2html .= "<font style='font-weight: bold;'>$tpeid[$i] : $tpcomment</font> $delcomment<BR>";
	}

	$comment2html = "<table width='650'><tr><td>$comment2html</td></tr></table>";



	#写真情報管理 ====================== ここから

	#表示のみ ---
	if($form{'changetpinfo'} eq "") {
		$q = "SELECT COUNT(tpid) AS cnt FROM hbjms_tptb WHERE tpid = '$tp'";
		&ExecSQL($q);
		$cnt = &GetValueFromSTH(1,"cnt");

		#写真の登録が既にあった場合 ---
		if($cnt > 0) {

			@qfld = qw(tpeid tpjid tpfolid);

			#写真情報取得 ---
			$q = "SELECT tpeid,tpjid,tpfolid FROM hbjms_tptb WHERE tpid = '$tp'";
			&ExecSQL($q);
			&GetValueFromSTH(2,"",*qfld);
			$tpinfo = "<font style='font-size: 10pt; background-color: pink; Padding: 2pt 3pt 2pt 3pt;'><i>$tpeid</i></font>";

			#プロジェクト名取得 ---
			$q = "SELECT jname FROM hbjms_jtb WHERE jid = '$tpjid'";
			&ExecSQL($q);
			$jname = &GetValueFromSTH(1,"jname");
			if($jname ne "") {
				$tpinfo .= " <font style='font-size: 10pt; background-color: #bbe1d8; Padding: 2pt 3pt 2pt 3pt;'><i>$jname</i></font>";
			}

			#フォルダ名取得 ---
			$q = "SELECT foln FROM hbjms_foltb WHERE folid = '$tpfolid'";
			&ExecSQL($q);
			$foln = &GetValueFromSTH(1,"foln");
			if($foln ne "") {
				$tpinfo .= " <font style='font-size: 10pt; background-color: LightGreen; Padding: 2pt 3pt 2pt 3pt;'><i>$foln</i></font>";
			}

			if($tpinfo ne "") {
				$tpinfo .= "<font style='font-size: 9pt;'>(<a href='$ThisFile?act=tp\&changetpinfo=1\&tp=$tp'>change</a>)</font> <br>";
			}

		#無い場合 ---
		} else {
			#写真がある時のみ ---
			if($tp ne "") {
				$iupit = "<a href='$ThisFile?act=tp\&iup=1\&tp=$tp'><font style='font-weight: bold; background-color: pink; padding: 2pt 5pt 2pt 5pt;'>_txttp007_</font></a> <p>";
			}
		}

	#変更処理の場合 ---
	} else {

		if($form{'changetpinfo'} eq "1") {

			@qfld = qw(tpeid tpjid tpfolid);

			#写真情報取得 ---
			$q = "SELECT tpeid,tpjid,tpfolid FROM hbjms_tptb WHERE tpid = '$tp'";
			&ExecSQL($q);
			&GetValueFromSTH(2,"",*qfld);

			#select tpeid ---
			if($tpeid ne "") {
				$pselected = $tpeid;
			}
			$qWHERE = " WHERE eflg = '1'";
			$seltpeid = &MakeSelFromTable("1","hbjms_etb","tpeid","eid","eid");

			#select tpjid ---
			if($tpjid ne "") {
				$pselected = $tpjid;
			}
			$qWHERE = " WHERE jflg = '1'";
			$seltpjname = &MakeSelFromTable("1","hbjms_jtb","tpjid","jid","jname");

			#select tpfolid ---
			if($tpfolid ne "") {
				$pselected = $tpfolid;
			}
			$qWHERE = " WHERE foljid = '$tpjid' AND folflg = '1'";
			$seltpfoln = &MakeSelFromTable("1","hbjms_foltb","tpfolid","folid","foln");
			$seltpfoln =~ s/<select name='tpfolid'>/<select name='tpfolid'><option value=''>ALL<\/option>/g;



			$tpinfo = join("","
				<form name='FrmHB' action='$ThisFile' method='post'>
				$seltpeid $seltpjname $seltpfoln
				<input type='submit' value='ok'>
				<input type='hidden' name='act' value='tp'>
				<input type='hidden' name='changetpinfo' value='2'>
				<input type='hidden' name='tp' value='$tp'>
				</form>
			");

		} elsif($form{'changetpinfo'} eq "2") {

			$q = "UPDATE hbjms_tptb SET tpeid = '$form{'tpeid'}',tpjid = '$form{'tpjid'}',tpfolid = '$form{'tpfolid'}' WHERE tpid = '$form{'tp'}'";
			&ExecSQL($q);

		}


	}
	#写真情報管理 ====================== ここまで

	#写真エリア作成 ---
	if($tp eq "") {
		$tparea = "<img src='/jobsite/images/nopicture.jpg' border='1' style='padding: 3pt 3pt 3pt 3pt;'> <br>";
	} else {
		$tparea = "<table border='0' $ac><tr><td>$iupit $tpinfo</td></tr><tr><td><img src='/jobsite/$pathtp$tp' style='padding: 3pt 3pt 3pt 3pt;'></td></tr></table>";
	}

	#ゴミ箱エリア ---
	if($eid eq "kojiro2ph\@yahoo.co.jp") {

		@qfld = qw(dtpid);
		$q = "SELECT tpid AS dtpid FROM hbjms_tptb WHERE tpflg = '0'";
		&ExecSQL($q);
		&SetFieldToArray(@qfld);
		for($i = 0; $i <= $#dtpid; $i++) {
			if(-e "$pathtp$dtpid[$i]") {

				if($form{'emptytrashbin'} eq "1") {
					unlink "$pathtp$dtpid[$i]";
					unlink "$pathtp_s$dtpid[$i]";
				} else {
					$strtrasharea .= "<img src='$pathtp_s$dtpid[$i]'> ";
				}
			}
		}

		$strtrasharea = "<a href='$ThisFile?act=tp\&emptytrashbin=1'>empty trash bin</a> <p> $strtrasharea";
	}


	#表示処理 ---
	$K = join("","

		$DBG

		<table $ac border='0'>
		<tr>
			<td $vat $ac>

			<table border='0'><tr><td>
			$tparea $comment2html $dellink
			</td></tr></table>

			</td>
			<td $vat>

			<font style='font-size: 25pt; font-weight: bold;'>_txttp001_</font>

			<table border='0'>
			<form name='FrmHB' action='$ThisFile' enctype=\"multipart/form-data\" method='post'>
			<tr><td $vac>
			<input type='file' name='tp' style='font-size: 18pt;'>
			</td><td $vac>
			<input type='image' src='/jobsite/images/btnupload.jpg' value='_txttp002_' style='font-size: 14pt; font-weight: bold;' width='60' alt='_txttp002_' title='_txttp002_'>
			</td></tr>
			<input type='hidden' name='act' value='tp'>
			<input type='hidden' name='upload' value='1'>
			</form>
			</table>

			$commenthtml
			$albumhtml 
			</td>
		</tr>
		</table>

		$strtrasharea

		<form name='FrmHBstpby' action='$ThisFile' method='post'>
		<input type='hidden' name='act' value='tp'>
		<input type='hidden' name='stpbyjid' value=''>
		</form>

		<form name='FrmHBstpbyfolid' action='$ThisFile' method='post'>
		<input type='hidden' name='act' value='tp'>
		<input type='hidden' name='stpbyfolid' value=''>
		</form>

		<script language='javascript'>
		<!--//
		function StpBy(v) {
			// alert(v);
			document.FrmHBstpby.stpbyjid.value = v;
			document.FrmHBstpby.submit();
		}
		function StpByFolID(v) {
			// alert(v);
			document.FrmHBstpbyfolid.stpbyfolid.value = v;
			document.FrmHBstpbyfolid.submit();
		}
		//-->
		</script>

		");
}


######################################################################
# tp 用ライブラリ
######################################################################

sub MarkColorForTP {

	$q = "SELECT tpfolid AS tmp FROM hbjms_tptb WHERE tpid = '$tmparray[$i]' AND tpflg = '1'";
	&ExecSQL($q);
	$tmp = &GetValueFromSTH(1,"tmp");
	if($tmp eq "") {
		$imgbd = " border='2' style='border-color: #FF3030;'";
	} else {
		$imgbd = " border='0'";
	}

}

sub ResizeGdsImg {

	local($imgpath,$savepath,$w,$h) = @_;

	#-- オブジェクト作成 --#
	my $image = Image::Magick->new;

	#-- 画像を読込む --#
	$image->Read($imgpath);

	#-- 現在の縦・横を取得 --#
	my ($now_width, $now_height) = $image->Get('width', 'height');

	if($now_width eq "") {
		return;
	}

	#print &PH;
	#print "imgpath:$imgpath width:$now_width";
	#exit(0);

	if($now_width > $now_height) {

		$hilitsu = $now_width / $w;
		$will_h = $now_height / $hilitsu;

		#-- 縮小／拡大 --#
		$image->Resize(
		          width  => $w
		        , height => $will_h
		        , blur   => 0.8
		);

	} else {

		$hilitsu = $now_height / $h;
		$will_w = $now_width / $hilitsu;

		#-- 縮小／拡大 --#
		$image->Resize(
		          width  => $will_w
		        , height => $h
		        , blur   => 0.8
		);

	}

	#-- 画像を保存する(JPEG) --#
	$image->Write($savepath);

}


1;
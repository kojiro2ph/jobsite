
use File::Copy;

sub file {

	#変数定義 ---
	$pathf = "file/";

	#ファイル管理　ホーム ---
	if($form{'step'} eq "") {



		#ファイルアップロード処理 --- ここから
		if($form{"upload"} eq "1") {

			# ① My Box の場合 ---
			if($form{"fcat"} eq "1") {

				if($formdata{"f_fname"} ne "") { 

					$tim = time;

					#新しいファイルをtp.jpgとして保存 ---
					&RecordBinaryFileData("$pathf" . "f_$tim",$formdata{"f_fdata"});

					#ファイルサイズ取得 ---
					$fsz = &GetSpecFileInfo("$pathf" . "f_$tim","size");

					# File 情報に追加 ---
					$q = join("","
						INSERT INTO hbjms_ftb 
							(fid,fn,fsz,fcat,fhol,ffolid,ffolbid,fjid,fsnd,fregdt,fflg) VALUES
							(
							 'f_$tim'
							,'$formdata{'f_fname'}'
							,$fsz
							,'$form{'fcat'}'
							,'$eid'
							,''
							,''
							,''
							,''
							,NOW()
							,'1')
					");
					&ExecSQL($q);

				}

			# ② Project File の場合 ---
			} elsif($form{"fcat"} eq "2") {

				if($formdata{"f_fname"} ne "") { 

					$tim = time;

					#新しいファイルをtp.jpgとして保存 ---
					&RecordBinaryFileData("$pathf" . "f_$tim",$formdata{"f_fdata"});

					#ファイルサイズ取得 ---
					$fsz = &GetSpecFileInfo("$pathf" . "f_$tim","size");

					# File 情報に追加 ---
					$q = join("","
						INSERT INTO hbjms_ftb 
							(fid,fn,fsz,fcat,fhol,ffolid,ffolbid,fjid,fsnd,fregdt,fflg) VALUES
							(
							 'f_$tim'
							,'$formdata{'f_fname'}'
							,$fsz
							,'$form{'fcat'}'
							,'$eid'
							,''
							,''
							,'$form{'sfbyjid'}'
							,''
							,NOW()
							,'1'
							)
					");

					$dbgq = $q;

					&ExecSQL($q);

				}


			# ③ Send Send の場合 ---
			} elsif($form{"fcat"} eq "3") {

				if($formdata{"f_fname"} ne "") { 

					$tim = time;

					#新しいファイルをtp.jpgとして保存 ---
					&RecordBinaryFileData("$pathf" . "f_$tim",$formdata{"f_fdata"});

					#ファイルサイズ取得 ---
					$fsz = &GetSpecFileInfo("$pathf" . "f_$tim","size");

					# File 情報に追加 ---
					$q = join("","
						INSERT INTO hbjms_ftb 
							(fid,fn,fsz,fcat,fhol,ffolid,ffolbid,fjid,fsnd,fregdt,fflg) VALUES
							(
							  'f_$tim'
							 ,'$formdata{'f_fname'}'
							 ,$fsz
							 ,'$form{'fcat'}'
							 ,'$form{'sendto'}'
							 ,''
							 ,''
							 ,''
							 ,'$eid'
							 ,NOW()
							 ,'1'
							)
					");
					&ExecSQL($q);

					#メール用変数格納 ---
					$sfn = $formdata{'f_fname'};
					($sendto1,$sendto2) = $form{'sendto'} =~ /(.*)\@(.*)/;
					$sctt = &ConvVal(&ReadFileData("html/mail_file_sndsnd1$lng\.txt",3));
					&KstdSendMail(1,$INI{"GROBAL-SendMailPath"},$eid,$form{'sendto'},"HBJMS FILE $eid sent file to you",$sctt);

				}

			}

		}

		# アップローダーを使った場合 --- [控え]
		if($formdata{"Filedata_fname"} ne "") { 

			$tim = time;

			#新しいファイルをtp.jpgとして保存 ---
			&RecordBinaryFileData("$pathf" . "f_$tim",$formdata{"Filedata_fdata"});

			#写真情報に追加 ---
			$q = join("","
				INSERT INTO hbjms_ftb 
					(fid,fn,fcat,fhol,flay,foln,fbos,fjid,fsnd,fregdt,fflg) VALUES
					('f_$tim','$formdata{'Filedata_fname'}','1','$eid','1','','','','',NOW(),'0')
			");
			&ExecSQL($q);

		}


		#アップロード完了処理 --- [控え]
		if($form{"upload"} eq "99") {
			$q = "UPDATE hbjms_ftb SET fhol = '$eid', fflg = '1' WHERE fn = '$form{'f'}' AND fhol = ''";
			&ExecSQL($q);
		}
		#ファイルアップロード処理 --- ここまで



		#ファイル削除の処理 --- ここから

		if($form{'delfile'} eq "1") {
			$q = "UPDATE hbjms_ftb SET fflg = '0' WHERE fid = '$form{'fid'}'";
			&ExecSQL($q);
		}

		#ファイル削除の処理 --- ここまで


		#ファイルビューページ作成処理 --- ここから
		if($form{'mdl'} eq "1") {

			$q = "SELECT fn FROM hbjms_ftb WHERE fid = '$form{'fid'}'";
			&ExecSQL($q);
			$tmpfn = &GetValueFromSTH(1,"fn");

			if($tmpfn =~ /\.flv/) {
				$flvtim = time;
				$flvpath = "/jobsite/file/tmp/$form{'fid'}.flv";
				$flvtitle = "$TITLE - $tmpfn";
				$flvurl = "http://www.hamadaboiler.com/jobsite/file/tmp/$flvtim\.html";
				$flvK = &ConvVal(&ReadFileData("html/user_flvview.html",3));
				&RecordFileData("file/tmp/$flvtim\.html",3,$flvK);
				$KFULL = "1";
				$K = &Blank(&ConvVal("_txtpleasewait_"),"/jobsite/file/tmp/$flvtim\.html","2");
				return;
			} elsif($tmpfn =~ /\.jpg/i or $tmpfn =~ /\.gif/i) {
				$imgtim = time;
				@tmpfn = split(/\./,$tmpfn);
				$imgext = $tmpfn[$#tmpfn];
				$imgext = lc($imgext);
				$imgpath = "/jobsite/file/tmp/$form{'fid'}\.$imgext";
				$imgtitle = "$TITLE - $tmpfn";
				$imgurl = "http://www.hamadaboiler.com/jobsite/file/tmp/$imgtim\.html";
				$imgK = &ConvVal(&ReadFileData("html/user_imgview.html",3));
				&RecordFileData("file/tmp/$imgtim\.html",3,$imgK);
				$KFULL = "1";
				$K = &Blank(&ConvVal("_txtpleasewait_"),"/jobsite/file/tmp/$imgtim\.html","2");
				return;
			}
		}
		#ファイルビューページ作成処理 --- ここまで




		#ラベル作成 ---
		$lblMyBox = "My Box";
		$lblPrjFile = "Project File";
		$lblSndSnd = "Send Send";


		#加工 ---  ここから


		# ---------------
		# My Box
		# ---------------


		# My Box ファイル一覧作成 --- ここから

		if($form{'myboxtfn'} eq "0") {
			$qMyBoxORDERBY = "ORDER BY fn";
		} elsif($form{'myboxtfn'} eq "1") {
			$qMyBoxORDERBY = "ORDER BY fn DESC";
		} elsif($form{'myboxtsz'} eq "0") {
			$qMyBoxORDERBY = "ORDER BY fsz";
		} elsif($form{'myboxtsz'} eq "1") {
			$qMyBoxORDERBY = "ORDER BY fsz DESC";
		}

		@qfld = qw(fid fn fsz fsnd);
		$q = "SELECT fid,fn,fsz,fsnd FROM hbjms_ftb WHERE (fcat = '1' OR fcat = '3') AND fhol = '$eid' AND fflg = '1' $qMyBoxORDERBY";
		&ExecSQL($q);
		&SetFieldToArray(@qfld);

		for($i = 0; $i <= $#fid; $i++) {

			if(-e "$pathf$fid[$i]") {

				#コラムの色　セット ---
				$tmpcol = &Parapara("#EFE8EF");

				#ファイルサイズ取得 ---
				$tmpfsizenum = &GetSpecFileInfo("$pathf$fid[$i]","size");
				$tmpfsizetotal = $tmpfsizetotal + $tmpfsizenum;
				$tmpfsize = &Fsize2Fsize($tmpfsizenum);

				# Send Send からきた場合 ---
				if($fsnd[$i] ne "") {
					$btnsndsnd = "<img src='/jobsite/images/hito.jpg' height='19px' title='$fsnd[$i]' alt='$fsnd[$i]'>\&nbsp;";
				} else {
					$btnsndsnd = "";
				}

				#ファイルの形式によってtargetを変える --- (新形式!!) ここから
				if($fn[$i] =~ /\.flv$/) {

					if(!-d "$pathf" . "tmp/") {
						mkdir("$pathf" . "tmp/", 0777);
					}

					if(!-e "$pathf" . "tmp/$fid[$i]\.flv") {
						copy("$pathf$fid[$i]", "$pathf" . "tmp/$fid[$i]\.flv");
					}

					$target = "target='lwin'";
					$myboxfilelink = "Javascript:ShowFLVMovie('dvmyboxfilepreview','/jobsite/file/tmp/$fid[$i]\.flv');";

					$btnliv = "<a href='$ThisFile?act=file\&mdl=1\&fid=$fid[$i]' target='_myself'><img src='/jobsite/images/icnliv.gif' border='0'></a>";

				} elsif($fn[$i] =~ /\.jpg$/i) {

					if(!-e "$pathf" . "tmp/$fid[$i]\.jpg") {
						copy("$pathf$fid[$i]", "$pathf" . "tmp/$fid[$i]\.jpg");
					}

					$target = "target='lwin'";
					$myboxfilelink = "Javascript:ShowJPGPreview('dvmyboxfilepreview','/jobsite/file/tmp/$fid[$i]\.jpg');";

					$btnliv = "<a href='$ThisFile?act=file\&mdl=1\&fid=$fid[$i]' target='_myself'><img src='/jobsite/images/icnliv.gif' border='0'></a>";

				} else {
					$target = "target='uwin'";
					$myboxfilelink = "$ThisFile?act=file\&step=dl\&fid=$fid[$i]";

					$btnliv = "";
				}
				#ファイルの形式によってtargetを変える --- (新形式!!) ここまで

				#マス作成 ---
				$strmyboxarea .= join("","
					<tr bgcolor='$tmpcol' onMouseover=\"this.style.backgroundColor='#98FB98'\" onMouseout=\"this.style.backgroundColor='$tmpcol'\">
					<td style='font-size: 12pt;' $al>$btnsndsnd<a href=\"$myboxfilelink\" title='download' alt='download' $target>$fn[$i]</a></td><td><a href='$ThisFile?act=file\&step=\&delfile=1\&fid=$fid[$i]' title='delete' alt='delete'><img src='/jobsite/images/btndel.gif' border='0'></a></td>
					<td style='font-size: 10pt;' $ar nowrap>$tmpfsize</td>
					</tr>
				");

			}

		}

		$tmpfsizetotal = &Fsize2Fsize($tmpfsizetotal);

		if($strmyboxarea eq "") {
			$strmyboxarea = "_txtfilemyboxnofile_";
		} else {

			if($form{'myboxtsz'} eq "1") {
				$strmyboxtsz = "<a href='$ThisFile?act=file\&myboxtsz=0'>size</a>";
			} else {
				$strmyboxtsz = "<a href='$ThisFile?act=file\&myboxtsz=1'>size</a>";
			}

			if($form{'myboxtfn'} eq "1") {
				$strmyboxtfn = "<a href='$ThisFile?act=file\&myboxtfn=0'>file name</a>";
			} else {
				$strmyboxtfn = "<a href='$ThisFile?act=file\&myboxtfn=1'>file name</a>";
			}



			$strmyboxarea = join("","
				<table width='100%'>
				<tr bgcolor='pink'><td $ac>$strmyboxtfn</td><td>\&nbsp;</td><td $ac>$strmyboxtsz</td></tr>
				$strmyboxarea
				<tr><td colspan='2' $ar>file size total:</td><td style='font-size: 15pt; font-weight: bold;' $ar nowrap>$tmpfsizetotal</td></tr>
				</table>
			");
		}

		# My Box ファイル一覧作成 --- ここまで

		# MyBox 文字列作成 ---
		$strMyBox = join("","
			<font style='font-size: 25pt; font-weight: bold;'>$lblMyBox</font>

			<form name='FrmHB4MyBox2'>

			<div id='dvmyboxfilepreview'></div>

			<p>

			$strmyboxarea

			</form>

			<form name='FrmHB4MyBox' action='$ThisFile' enctype=\"multipart/form-data\" method='post'>
			<input type='file' name='f' style='font-size: 10pt;'>
			<input type='image' src='/jobsite/images/btnupload.jpg' value='_txttp002_' width='30' alt='_txttp002_' title='_txttp002_'>
			<input type='hidden' name='act' value='file'>
			<input type='hidden' name='upload'value='1'>
			<input type='hidden' name='fcat'value='1'>
			</form>
		");

		# ---------------
		# Project File
		# ---------------

		#フィルタリング情報保存 ---
		if($form{'sfbyjid'} ne "") {
			$q = "UPDATE hbjms_cidmanagetb SET esfbyjid = '$form{'sfbyjid'}' WHERE cid = '$cid'";
			&ExecSQL($q);
			$esfbyjid = $form{'sfbyjid'};
		}



		#フィルタリングエリア作成 ---
		$qWHERE = "WHERE jflg = '1'";
		if($esfbyjid ne "") {
			$pselected = $esfbyjid;
		}
		$selesfbyjid = &MakeSelFromTable("1","hbjms_jtb","sfbyjid","jid","jname");
		$selesfbyjid =~ s/<select name='sfbyjid'>/<select name='sfbyjid' onChange="SfBy(this.options[this.options.selectedIndex].value);" style='font-size:14pt; font-weight: bold; background-color: #FFFF66;'>/g;


		# Project File ファイル一覧作成 --- ここから

		if($form{'prjfiletfn'} eq "0") {
			$qPrjFileORDERBY = "ORDER BY fn";
		} elsif($form{'prjfiletfn'} eq "1") {
			$qPrjFileORDERBY = "ORDER BY fn DESC";
		} elsif($form{'prjfiletsz'} eq "0") {
			$qPrjFileORDERBY = "ORDER BY fsz";
		} elsif($form{'prjfiletsz'} eq "1") {
			$qPrjFileORDERBY = "ORDER BY fsz DESC";
		}

		@qfld = qw(fid fn fsz fhol);
		@fid = ();
		@fn = ();
		@fsz = ();
		@fhol = ();

		$q = "SELECT fid,fn,fsz,fhol FROM hbjms_ftb WHERE fcat = '2' AND fjid = '$esfbyjid' AND fflg = '1' $qPrjFileORDERBY";
		&ExecSQL($q);
		&SetFieldToArray(@qfld);

		for($i = 0; $i <= $#fid; $i++) {

			if(-e "$pathf$fid[$i]") {

				#コラムの色　セット ---
				$tmpcol = &Parapara("#EFE8EF");

				#ファイルサイズ取得 ---
				$tmpfsizenum = &GetSpecFileInfo("$pathf$fid[$i]","size");
				$tmpfsizetotal = $tmpfsizetotal + $tmpfsizenum;
				$tmpfsize = &Fsize2Fsize($tmpfsizenum);

				#削除ボタン作成(自分がアップロードした場合は削除可能) ---
				if($fhol[$i] eq $eid) {
					$strdel = "<a href='$ThisFile?act=file\&step=\&delfile=1\&fid=$fid[$i]' title='delete' alt='delete'><img src='/jobsite/images/btndel.gif' border='0'></a>";
				} else {
					$strdel = "<img src='/jobsite/images/hito.jpg' width='20px' title='$fhol[$i]' alt='$fhol[$i]'>";
				}

				#ファイルの形式によってtargetを変える --- (新形式!!) ここから
				if($fn[$i] =~ /\.flv$/) {

					if(!-d "$pathf" . "tmp/") {
						mkdir("$pathf" . "tmp/", 0777);
					}

					if(!-e "$pathf" . "tmp/$fid[$i]\.flv") {
						copy("$pathf$fid[$i]", "$pathf" . "tmp/$fid[$i]\.flv");
					}

					$target = "";
					$prjfilelink = "Javascript:ShowFLVMovie('dvprjfilepreview','/jobsite/file/tmp/$fid[$i]\.flv');";

					$btnliv = "<a href='$ThisFile?act=file\&mdl=1\&fid=$fid[$i]' target='_myself'><img src='/jobsite/images/icnliv.gif' border='0'></a>";

				} elsif($fn[$i] =~ /\.jpg$/i) {

					if(!-e "$pathf" . "tmp/$fid[$i]\.jpg") {
						copy("$pathf$fid[$i]", "$pathf" . "tmp/$fid[$i]\.jpg");
					}

					$target = "";
					$prjfilelink = "Javascript:ShowJPGPreview('dvprjfilepreview','/jobsite/file/tmp/$fid[$i]\.jpg');";

					$btnliv = "<a href='$ThisFile?act=file\&mdl=1\&fid=$fid[$i]' target='_myself'><img src='/jobsite/images/icnliv.gif' border='0'></a>";

				} else {
					$target = "target='uwin'";
					$prjfilelink = "$ThisFile?act=file\&step=dl\&fid=$fid[$i]";

					$btnliv = "";
				}
				#ファイルの形式によってtargetを変える --- (新形式!!) ここまで


				#マス作成 ---
				$strprjfilearea .= join("","
					<tr bgcolor='$tmpcol' onMouseover=\"this.style.backgroundColor='#98FB98'\" onMouseout=\"this.style.backgroundColor='$tmpcol'\">
					<td style='font-size: 12pt;' $al><a href=\"$prjfilelink\" title='$fhol[$i]' alt='$fhol[$i]' $target>$fn[$i]</a> $btnliv</td>
					<td>$strdel</td>
					<td style='font-size: 10pt;' $ar nowrap>$tmpfsize</td>
					</tr>
					");

			}

		}

		$tmpfsizetotal = &Fsize2Fsize($tmpfsizetotal);

		if($strprjfilearea eq "") {
			$strprjfilearea = "<i>No File</i>";
		} else {

			if($form{'prjfiletsz'} eq "1") {
				$strprjfiletsz = "<a href='$ThisFile?act=file\&prjfiletsz=0'>size</a>";
			} else {
				$strprjfiletsz = "<a href='$ThisFile?act=file\&prjfiletsz=1'>size</a>";
			}

			if($form{'prjfiletfn'} eq "1") {
				$strprjfiletfn = "<a href='$ThisFile?act=file\&prjfiletfn=0'>file name</a>";
			} else {
				$strprjfiletfn = "<a href='$ThisFile?act=file\&prjfiletfn=1'>file name</a>";
			}



			$strprjfilearea = join("","
				<table width='100%'>
				<tr bgcolor='pink'><td $ac>$strprjfiletfn</td><td>\&nbsp;</td><td $ac>$strprjfiletsz</td></tr>
				$strprjfilearea
				<tr><td colspan='2' $ar>file size total:</td><td style='font-size: 15pt; font-weight: bold;' $ar nowrap>$tmpfsizetotal</td></tr>
				</table>
			");
		}

		# Project File ファイル一覧作成 --- ここまで



		# Project File 文字列作成 ---
		$strPrjFile = join("","
			<font style='font-size: 25pt; font-weight: bold;'>$lblPrjFile</font>

			<form name='FrmHB4PrjFile' action='$ThisFile' enctype=\"multipart/form-data\" method='post'>

			<p>

			$selesfbyjid

			<div id='dvprjfilepreview'></div>

			<p>

			$strprjfilearea

			<p>

			<input type='file' name='f' style='font-size: 10pt;'>
			<input type='image' src='/jobsite/images/btnupload.jpg' value='_txttp002_' width='30' alt='_txttp002_' title='_txttp002_'>
			<input type='hidden' name='act' value='file'>
			<input type='hidden' name='upload'value='1'>
			<input type='hidden' name='fcat'value='2'>
			</form>
		");



		# ---------------
		# Send Send
		# ---------------
		@qfld = qw(eid);
		$q = "SELECT eid FROM hbjms_etb WHERE eflg = '1'";
		&ExecSQL($q);
		&SetFieldToArray(@qfld);

		$j = -1;
		for($i = 0; $i <= $#eid; $i++) {

			($eid1,$eid2) = $eid[$i] =~ /(.*)\@(.*)/;

			if(length($eid1) > 10) {
				$eid1 = substr($eid1,0,10);
			}

			$strhumanarea .= "<td bgcolor='#FFFFFF' $ac $vat onClick=\"SelPerson('$eid[$i]')\" onMouseover=\"this.style.backgroundColor='#FFCC00'\"onMouseout=\"this.style.backgroundColor='#FFFFFF'\"><img src='/jobsite/images/hito.jpg'> <br> <font style='font-size: 10pt;'>$eid1</font> </td>";

			$j++;

			if(($j+1)%4 eq 0 and $j ne 0) {
				$strhumanarea .= "</tr><tr>";
			}
		}

		$strhumanarea = "<div id='dvsndsndupload' style=\"visibility = \'hidden\'\"></div><div id='dvselperson'><table width='100%' border='0'><tr>$strhumanarea</tr></table></div>";

		$strSndSnd = "<font style='font-size: 25pt; font-weight: bold;'>$lblSndSnd</font> <p> $strhumanarea";


		# ---------------
		# Trash Area
		# ---------------

		if($eid eq "kojiro2ph\@yahoo.co.jp") {
			
			@qfld = qw(fid fn fsz fhol);
			@fid = ();
			@fn = ();
			@fsz = ();
			@fhol = ();

			$q = "SELECT fid,fn,fsz,fhol FROM hbjms_ftb WHERE fflg = '0'";
			&ExecSQL($q);
			&SetFieldToArray(@qfld);

			for($i = 0; $i <= $#fid; $i++) {
				if(-e "$pathf$fid[$i]") {
					if($form{'emptytrashbin'} eq "1") {
						unlink "$pathf$fid[$i]";
					} else {
						$strtrasharea .= "$fn[$i] ($fhol[$i])<br>";
					}
				}
			}

			$strtrasharea = "<a href='$ThisFile?act=file\&emptytrashbin=1'>empty trash bin</a> <p> $strtrasharea";
		}

		#加工 ---  ここまで

		$H = join("","
			<script type='text/javascript'>
			<!--//
			function SelPerson(eid) {
				document.getElementById('dvselperson').style.visibility = \"hidden\";
				document.getElementById('dvsndsndupload').style.visibility = \"visible\";
				document.getElementById('dvsndsndupload').innerHTML = \"<table><tr><td align='center'><form name='FrmHB4SndSnd' action='$ThisFile' enctype='multipart/form-data' method='post'><img src='/jobsite/images/hito.jpg'> <p>\" + eid + \"<p> <input type='file' name='f' style='font-size: 10pt;'><input type='image' src='/jobsite/images/btnupload.jpg' value='_txttp002_' width='30' alt='_txttp002_' title='_txttp002_'><input type='hidden' name='act' value='file'><input type='hidden' name='upload'value='1'><input type='hidden' name='fcat'value='3'><input type='hidden' name='sendto'value='\" + eid + \"'></form> <p> <p> <img src='/jobsite/images/btnrf.jpg' onClick='BackToSelPerson();'> </td></tr></table>\";
			}
			function BackToSelPerson() {
				document.getElementById('dvsndsndupload').innerHTML = \"\";
				document.getElementById('dvsndsndupload').style.visibility = \"hidden\";
				document.getElementById('dvselperson').style.visibility = \"visible\";
			}
			function ShowFLVMovie(dv,flv) {
				document.getElementById(dv).innerHTML = \"<object type='application/x-shockwave-flash' width='320' height='262' wmode='transparent' data='/jobsite/swf/flvplayer.swf?file=\" + flv + \"\&autostart=true'><param name='movie' value='/jobsite/swf/flvplayer.swf?file=\" + flv + \"\&autostart=true' /><param name='wmode' value='transparent' /></object>\";
			}
			function ShowJPGPreview(dv,jpg) {
				document.getElementById(dv).innerHTML = \"<img src='\" + jpg + \"' width='320'>\";
			}
			//-->
			</script>
		");

		#表示 ---
		$K = join("","

			<table width='100%' height='80%' border='0'><tr><td $vat>

			<!-- browse section -->
			<table width='100%' height='70%' border='0'>
			<tr>
			<td width='33%' $ac $vat>
			$strMyBox
			</td>
			<td width='33%' $ac $vat>
			$strPrjFile
			</td>
			<td width='34%' $ac $vat>
			$strSndSnd
			</td>
			</tr>
			</table>


			$strtrasharea


			<!-- js section -->
			<form name='FrmHBstpby' action='$ThisFile' method='post'>
			<input type='hidden' name='act' value='file'>
			<input type='hidden' name='sfbyjid' value=''>
			</form>

			<script language='javascript'>
			<!--//
			function SfBy(v) {
				// alert(v);
				document.FrmHBstpby.sfbyjid.value = v;
				document.FrmHBstpby.submit();
			}
			//-->
			</script>
		");


	# ダウンロードを選んだ場合 ---
	} elsif($form{'step'} eq "dl") {
		if(-e "$pathf" . $form{'fid'}) {
			$q = "SELECT fn FROM hbjms_ftb WHERE fid = '$form{'fid'}'";
			&ExecSQL($q);
			$fn = &GetValueFromSTH(1,"fn");

			#use File::Copy;
			#
			#$tim = time;
			#mkdir("$pathf$tim/", 0777);
			#
			#copy("$pathf$form{'fid'}", "$pathf" . "$tim/$fn");
			#
			#$KFULL = "1";
			#$K = &Blank("Downloading...","$pathf$tim/$fn",3);

			print "Content-Type: application/octet-stream;\n";

			#IEとFirefoxの判別 ---
			if($ENV{"HTTP_USER_AGENT"} =~ /MSIE/i) {
				($fn,$ext) = $fn =~ /(.*)\.(.*)/;
				$fn = &my_utf8_pe($fn) . "." . $ext;
				print "Content-Disposition: attachment; filename=$fn\n";
			} elsif($ENV{"HTTP_USER_AGENT"} =~ /Firefox/i) {
				print "Content-Disposition: attachment; filename\*=\"UTF-8''$fn\"\n";
			} else {
				print "Content-Disposition: attachment; filename\*=\"UTF-8''$fn\"\n";
			}

			print "\n";

			open(FDL,"$pathf$form{'fid'}");
			binmode(FDL);
			binmode(STDOUT);
			print <FDL>;
			close(FDL);

			&Quit_System;

			exit(0);
		}

	# 枠表示 ---
	} elsif($form{'step'} eq "w") {

		$KFULL = "1";

		$K = &ConvVal(&ReadFileData("html/user_file_w.html",3));

	# 枠表示 ---
	} elsif($form{'step'} eq "blank") {

		$KFULL = "1";

		$K = &Blank("");

	}




}

1;
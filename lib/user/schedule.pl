
sub schedule {

	$K = "schedule";

	if($form{'step'} eq "") { $form{'step'} = "edit"; }

	#閲覧の場合 ---
	if($form{'step'} eq "") {
	#編集の場合 ---
	} elsif($form{'step'} eq "edit") {


		#バッチ登録処理 --- ここから
		if($form{'batchreg'} eq "1") {

			$form{'bt'} =~ s/\r//g;
			@bt = split(/\n/,$form{'bt'});

			$tid = int(time);

			for($i = 1; $i <= $#bt; $i++) {
				#変数整理 ---
				$tid++;
				@lbt = split(/\t/,$bt[$i]);
				$lbt[1] =~ s/\s+$//g;
				$lbt[2] =~ s/\s+$//g;

				#既にあったら登録しない ---
				$q = "SELECT COUNT(tid) AS cnt FROM hbjms_ttb WHERE tntw = '$lbt[1]' AND tjid = '$ejid'";
				&ExecSQL($q);
				$cnt = &GetValueFromSTH(1,"cnt");
				if($cnt >= 1) {
					$strq .= "<font style='color: red;'>$q</font>\n";
					next;
				}

				#登録SQL文 ---
				$q = join("","
					INSERT INTO hbjms_ttb
						(tid,tjid,tno,tnen,tncn,tnjp,tntw,tst,ten,tregdt,tflg)
					VALUES
						('$tid','$ejid','$lbt[0]','$tnen','$tncn','$tnjp','$lbt[1]','$lbt[3]','$lbt[4]',NOW(),'1')
				");
				&ExecSQL($q);

				#デバグ用 ---
				$strq .= $q;
			}

		}
		#バッチ登録処理 --- ここまで



		#スケジュール表作成 --- ここから

		#このプロジェクトの最初の作業日を取得 ---
		$q = "SELECT tst FROM hbjms_ttb WHERE tst != '0000-00-00' ORDER BY tst LIMIT 0,1";
		&ExecSQL($q);
		$fday = &GetValueFromSTH(1,"tst");

		#このプロジェクトの最後の作業日を取得 ---
		$q = "SELECT ten FROM hbjms_ttb WHERE tst != '0000-00-00' ORDER BY tst DESC LIMIT 0,1";
		&ExecSQL($q);
		$lday = &GetValueFromSTH(1,"ten");

		#今日の日付を取得 ---
		$nw = &GetSpecDateString(time,"year") . "-" . sprintf("%02d",&GetSpecDateString(time,"mon")) . "-" . sprintf("%02d",&GetSpecDateString(time,"mday"));

		#最初と最後までの日数を取得 ---
		$q = "SELECT DATEDIFF('$lday','$fday') AS tday";
		&ExecSQL($q);
		$tday = &GetValueFromSTH(1,"tday");

		#昇順の処理 --- ここから

		if($form{'dc'} ne "") {

			#名称の処理 ---
			if($form{'dc'} eq "tn") {
				$form{'dc'} = $form{'dc'} . $lng;
			}

			# a => b
			if($form{'srt'} eq "") {
				$srt = "a";
			} else {
				$srt = $form{'srt'};
			}

			if($srt eq "a") {
				$qdesc = "";
				$srt = "b";
			} else {
				$qdesc = "DESC";
				$srt = "a";
			}
			$qscheduleORDERBY = "ORDER BY $form{'dc'} $qdesc";
		}

		#昇順の処理 --- ここまで



		@qfld = qw(tid tno tty tnen tncn tnjp tntw tst ten tdc tds);
		$q = "SELECT tid,tno,tty,tnen,tncn,tnjp,tntw,tst,ten,DATEDIFF(ten,tst) AS tdc,DATEDIFF(tst,'$fday') AS tds FROM hbjms_ttb WHERE tjid = '$ejid' AND tflg = '1' $qscheduleORDERBY";
		&ExecSQL($q);
		&SetFieldToArray(@qfld);

		for($i = 1; $i <= $#tid; $i++) {

			$tn = ${"tn" . $lng}[$i];

			$tborder = "<table width='$tdc[$i]' height='20' bgcolor='red' style='position:relative; left: $tds[$i];'><tr><td><font style='font-size:1pt;'>\&nbsp;</font></td></tr></table>";

			#作業日数が空の場合 ---
			if($tdc[$i] eq "") {
				$tdc[$i] = "\&nbsp;";
			}

			#行の色分け ---
			$tmpnw = $nw;
			$tmpten = $ten[$i];
			$tmpnw =~ s/\-//g;
			$tmpten =~ s/\-//g;
			if($tmpnw > $tmpten) {
				$bgcol = "bgcolor='Silver'";
			} else {
				$bgcol = "bgcolor='#FFDAB9'";
			}


			#この言語の用語が空の場合は自動翻訳して暫時登録をする ---
			if(${"tn" . $lng}[$i] eq "") {

				$nama = "1";

				${"tn" . $lng}[$i] = &TT("1","",${"tntw"}[$i]);
				$tmptn = ${"tn" . $lng}[$i];

				#暫時登録実行 ---
				$q = "UPDATE hbjms_ttb SET tn$lng = '$tmptn' WHERE tid = '$tid[$i]'";
				&ExecSQL($q);

				$tn = ${"tn" . $lng}[$i];

			}


			$strtlist .= join("","
				<tr $bgcol>
				<td $ar width='50'>$tno[$i]</td>
				<td>$tn</td>
				<td>$tst[$i]</td>
				<td>$ten[$i]</td>
				<td $ar><font style='font-size: 18pt; font-weight: bold;'>$tdc[$i]</font></td>
				<td width='$tday'>$tborder</td>
				</tr>
			");
		}

		$strtlist = join("","
			<font style='font-size: 16pt; font-weight: bold;'>Total Working Days : $tday</font>
			<p>
			<table border='0' $cs{'2'} $cp{'3'} style='font-size: 14pt;'>
			<tr bgcolor='pink'>
			<td $ac><a href='$ThisFile?act=schedule\&step=edit\&dc=tno\&srt=$srt'>No.</a></td>
			<td $ac><a href='$ThisFile?act=schedule\&step=edit\&dc=tn\&srt=$srt'>Name</a></td>
			<td $ac><a href='$ThisFile?act=schedule\&step=edit\&dc=tst\&srt=$srt'>Start</a></td>
			<td $ac><a href='$ThisFile?act=schedule\&step=edit\&dc=ten\&srt=$srt'>Finish</a></td>
			<td $ac><a href='$ThisFile?act=schedule\&step=edit\&dc=tdc\&srt=$srt'>Days</a></td>
			<td $ac><a href='$ThisFile?act=schedule\&step=edit\&dc=tst\&srt=$srt'>Border</a></td>
			</tr>
			$strtlist
			</table>
		");


		#スケジュール表作成 --- ここまで


		#バッチ登録フォームを表示する (管理者のみ) ---
		if($eid eq "kojiro2ph\@yahoo.co.jp") {
			$strbatchreg = join("","
				<b>Batch Registry</b> $#bt
				<table>
				<form action='$ThisFile' method='post'>
				<tr><td>
				<textarea name='bt' rows='20' cols='100'></textarea>
				</td></tr>
				<tr><td>
				<input type='submit' value='ok'>
				<input type='reset' value='cancel'>
				</td></tr>
				<input type='hidden' name='act' value='schedule'>
				<input type='hidden' name='step' value='edit'>
				<input type='hidden' name='batchreg' value='1'>
				</form>
				</table>
			");
		}







		#表示 ---
		$K = join("","
			<table width='90%' $ac><tr><td>

			<p>

			<table width='100%' $cp{'5'} bgcolor='#bbe1d8'><tr><td>
			<font style='font-size:16pt; font-weight: bold;'>_txtheadermenu005_</font>
			</td></tr></table>

			<p>

			$strtlist

			<p>

			$strbatchreg

			</td></tr></table>
		");
	}


}

1;
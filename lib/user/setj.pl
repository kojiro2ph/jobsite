
sub setj {

	if($form{'step'} eq "") {

		$qWHERE = "WHERE jflg = '1'";
		if($ejid ne "") {
			$pselected = $ejid;
		}
		$selj = &MakeSelFromTable("1","hbjms_jtb","ejid","jid","jname");
		$selj =~ s/<select name='ejid'>/<select name='ejid' style='font-size:14pt; font-weight: bold; background-color: #FFFF66;'>/g;

		$K = join("","
			<table width='100%' height='80%'><tr><td $vac $ac>
			<form action='$ThisFile' method='post'>
			<font style='font-size: 16pt;'>_txtsetj001_ :</font> $selj
			\&nbsp;
			<input type='submit' value='OK' style='font-size: 16pt;'>
			<input type='hidden' name='act' value='setj'>
			<input type='hidden' name='step' value='2'>
			</form>
			</td></tr></table>
		");

	} elsif($form{'step'} eq "2") {

		$q = "UPDATE hbjms_cidmanagetb SET ejid = '$form{'ejid'}',estpbyjid = '$form{'ejid'}',esfbyjid = '$form{'ejid'}' WHERE cid = '$cid'";
		&ExecSQL($q);

		$KFULL = "1";
		$K = &Blank(&ConvVal("_txtpleasewait_"),"$ThisFile?act=menu","2");


	} elsif($form{'step'} eq "lng") {

		if($form{'substep'} eq "") {

			@qfld = qw(lngid lngname);
			&ExecSQL("SELECT lngid,lngname FROM hbjms_lngtb WHERE lngflag = '1' ORDER BY lngname");
			&SetFieldToArray(@qfld);

			for($i = 0; $i <= $#lngid; $i++) {
				$lngselarea .= join("","
					<tr>
					<td><a href='$ThisFile?act=setj\&step=lng\&substep=2\&setlngto=$lngid[$i]'><img src='/jobsite/images/flg$lngid[$i]\.gif' border='0' width='150' title='SELECT' alt='SELECT'></a></td>
					<td $ac $vac>$lngname[$i]</td>
					</tr>
				");
			}

			$lngselarea = "<table $cp{'10'} $cs{'5'} style='font-size: 22pt; font-weight: bold;'>$lngselarea</table>";

			$K = join("","

				<table width='100%' height='85%' border='0' $cp{'0'} $cs{'0'}>
				<tr><td $ac $vac>$lngselarea</td></tr>
				</table>

			");

		} elsif($form{'substep'} eq "2") {

			$q = "UPDATE hbjms_cidmanagetb SET elng = '$form{'setlngto'}' WHERE cid = '$cid'";
			&ExecSQL($q);

			$KFULL = "1";
			$K = &Blank(&ConvVal("_txtpleasewait_"),"$ThisFile?act=menu","2");

		}


	} elsif($form{'step'} eq "fol") {

		if($form{'foltype'} eq "tp") {

			if($form{'substep'} eq "") {

				#プロジェクト名取得 ---
				$q = "SELECT jname FROM hbjms_jtb WHERE jid = '$form{'jid'}'";
				&ExecSQL($q);
				$jname = &GetValueFromSTH(1,"jname");

				#既存フォルダ一覧 ---
				@qfld = qw(foln);
				$q = "SELECT foln FROM hbjms_foltb WHERE foltype = 'tp' AND foljid = '$form{'jid'}' AND folflg = '1'";
				&ExecSQL($q);
				&SetFieldToArray(@qfld);

				for($i = 0; $i <= $#foln; $i++) {
					$existsfolarea .= "<tr><td $vam><img src='/jobsite/images/btnfol.jpg'></td><td $vam>$foln[$i]</td></tr>";
				}
				if($existsfolarea eq "") {
					$existsfolarea = "<i>No Nolder</i>";
				} else {
					$existsfolarea = "<table style='font-size: 16pt;'>$existsfolarea</table>";
				}

				#表示 ---
				$K = join("","

				<table width='100%' height='80%'><tr><td $ac $vam>

				<!--// フォルダ登録フォーム //-->
				<form action='$ThisFile' method='post'>

				<font style='font-size: 25pt; font-weight: bold;'>$jname</font>
				<p>
				<font style='font-size: 18pt;'>_txtsetj002_ : </font>
				<input type='text' name='nfoln' style='font-size: 16pt; background-color: #FFFF66;' size='18'>

				<input type='submit' value='OK' style='font-size: 16pt;'>
				<input type='hidden' name='act' value='setj'>
				<input type='hidden' name='step' value='fol'>
				<input type='hidden' name='foltype' value='tp'>
				<input type='hidden' name='jid' value='$form{'jid'}'>
				<input type='hidden' name='substep' value='2'>
				</form>

				<br> <br>

				$existsfolarea

				</td></tr></table>

				");


			} elsif($form{'substep'} eq "2") {

				#空でなければ処理に入る ---
				if($form{'nfoln'} ne "") {

					#同一ファイル名がないか確認する ---
					$q = "SELECT COUNT(folid) AS cnt FROM hbjms_foltb WHERE foltype = 'tp' AND foljid = '$form{'jid'}' AND folflg = '1' AND foln = '$form{'nfoln'}'";
					&ExecSQL($q);
					$cnt = &GetValueFromSTH(1,"cnt");

					if($cnt > 0) {
						$errflg = "1";
						push(@errmsg,"_txtsetj003_");
					}

					#追加判別処理 ---
					if($errflg ne "1") {

						#フォルダＩＤ作成 ---
						$folid = time;

						$q = join("","
							INSERT INTO hbjms_foltb 
								(folid,foln,foltype,foljid,folregdt,folflg) VALUES
								('$folid','$form{'nfoln'}','$form{'foltype'}','$form{'jid'}',NOW(),'1')
						");

						&ExecSQL($q);


						# しばらくお待ちください画面 ---
						$KFULL = "1";
						$K = &Blank(&ConvVal("_txtpleasewait_"),"$ThisFile?act=tp","2");

					}

				}

			}
		}

	}

}

1;

sub mantb {

	if($form{'tb'} eq "jtb") {

		#プロジェクトの追加の場合 ---
		if($form{'step'} eq "man_jobsite") {

			if($form{'reg_jobsite'} eq "1" and $form{'jname'} ne "") {

				#重複確認 ---
				$q = "SELECT COUNT(jid) AS cnt FROM hbjms_jtb WHERE jcountry = '$form{'countryid'}' AND jname = '$form{'jname'}' AND jflg = '1'";
				$q2 = $q;
				&ExecSQL($q);
				$cnt = &GetValueFromSTH(1,"cnt");
				if($cnt > 0) {
					$errmsg = "you have already same project name";
				}

				if($errmsg eq "") {

					$q = join("","
						INSERT INTO hbjms_jtb
							(jid,jname,jcountry,jregdt,jflg)
							VALUES
							('$form{'jid'}'
							,'$form{'jname'}'
							,'$form{'countryid'}'
							,NOW()
							,'1'
							)
					");
					&ExecSQL($q);
				}
			}

			#編集１ ---
			if($form{'edit'} eq "1") {

				@qfld = qw(jid jname jcountry);
				$q = "SELECT jid,jname,jcountry FROM hbjms_jtb WHERE jid = '$form{'edtjid'}' AND jflg = '1'";
				&ExecSQL($q);
				&GetValueFromSTH(2,"",*qfld);

				$pselected = $jcountry;
				$seljcountry = &MakeSelFromTable("1","hbjms_countrytb","countryid","countryid","countryname$lng");

				$regoredit = "edit";
				$regoreditval = "2";

			#編集２ ---
			} elsif($form{'edit'} eq "2") {

				#空防止 ---
				if($form{'jname'} eq  "") {
					$errmsg = "please put project name";
				}

				#重複確認 ---
				$q = "SELECT COUNT(jid) AS cnt FROM hbjms_jtb WHERE jcountry = '$form{'countryid'}' AND jname = '$form{'jname'}' AND jflg = '1'";
				$q2 = $q;
				&ExecSQL($q);
				$cnt = &GetValueFromSTH(1,"cnt");
				if($cnt > 0) {
					$errmsg = "you have already same project name";
				}

				#エラーでなければ編集実行 ---
				if($errmsg eq "") {

					$q = join("","
						UPDATE hbjms_jtb
							SET 
								jname		= '$form{'jname'}'
								,jcountry	= '$form{'countryid'}'
							WHERE
								jid	= '$form{'jid'}'
					");
					&ExecSQL($q);

				}

				$regoredit = "reg_jobsite";
				$regoreditval = "1";

			#削除 ---
			} elsif($form{'del'} eq "1") {

				$q = join("","
					UPDATE hbjms_jtb
						SET 
							jflg	= '0'
						WHERE
							jid	= '$form{'deljid'}'
				");
				&ExecSQL($q);

				$jid = time;
				$qWHERE = " WHERE countryflg = '1'";
				$seljcountry = &MakeSelFromTable("1","hbjms_countrytb","countryid","countryid","countryname$lng");

				$regoredit = "reg_jobsite";
				$regoreditval = "1";

			#そのほか ---
			} else {
				$jid = time;
				$qWHERE = " WHERE countryflg = '1'";
				$seljcountry = &MakeSelFromTable("1","hbjms_countrytb","countryid","countryid","countryname$lng");

				$regoredit = "reg_jobsite";
				$regoreditval = "1";
			}


			#プロジェクト一覧作成 ---
			@qfld = qw(jid jname countryname);
			&ExecSQL("SELECT hbjms_jtb.jid AS jid,hbjms_jtb.jname AS jname,hbjms_countrytb.countryname$lng AS countryname FROM hbjms_jtb,hbjms_countrytb WHERE hbjms_jtb.jcountry = hbjms_countrytb.countryid AND hbjms_jtb.jflg = '1'");
			&SetFieldToArray(@qfld);

			for($i = 0; $i <= $#jid; $i++) {



				$jtable .= join("","
					<tr>
						<td>$jid[$i]</td>
						<td>$jname[$i]</td>
						<td>$countryname[$i]</td>
						<td><a href='$ThisFile?act=mantb\&tb=jtb\&step=man_jobsite\&edit=1\&edtjid=$jid[$i]'>edit</a></td>
						<td><a href='$ThisFile?act=mantb\&tb=jtb\&step=man_jobsite\&del=1\&deljid=$jid[$i]'>delete</a></td>
					</tr>
				");
			}

			if($jtable ne "") {
				#for($i = 0; $i <= $#qfld; $i++) {
				#	$tbl_h .= "<td $ac>$qfld[$i]</td>";
				#}
				$jtable = join("","<table border='1' $cp{'2'} $cs{'2'}>
						<tr bgcolor='pink'>
						<td>_txtmantbjtba001_</td>
						<td>_txtmantbjtba002_</td>
						<td>_txtmantbjtba003_</td>
						<td>_txtmantbjtba004_</td>
						<td>_txtmantbjtba005_</td>
						</tr>
						$jtable
						</table>
						<p>
					");
			} else {
				$jtable = "txtmantbcountry006<p>";
			}

			#表示 ---
			$K = join("","

				$jtable

				<p>
				$errmsg

				_txtmantbjtba006_
				<table>
				<form action='$ThisFile' method='post'>
				<tr><td>_txtmantbjtba002_ : </td><td><input type='text' name='jname' value='$jname' size='30'></td></tr>
				<tr><td>_txtmantbjtba003_ : </td><td>$seljcountry</td></tr>
				<tr><td colspan='2'>
				<input type='submit' value='ok'>
				<input type='reset' value='cancel'>
				</td></tr>
				<input type='hidden' name='act' value='mantb'>
				<input type='hidden' name='tb' value='jtb'>
				<input type='hidden' name='step' value='man_jobsite'>
				<input type='hidden' name='$regoredit' value='$regoreditval'>
				<input type='hidden' name='jid' value='$jid'>

				</form>
				</table>
			");
		}

	#国テーブル管理 ---
	} elsif($form{'tb'} eq "countrytb") {

		#土台 ---
		if($form{'step'} eq "") {

			#登録実行 ---
			if($form{'reg_country'} eq "1" and $form{'countrynameen'} ne "") {
				$q = join("","
					INSERT INTO hbjms_countrytb
						(countryid,countrynameen,countrynamecn,countrynamejp,countrynametw,countryflg)
						VALUES
						('$form{'countryid'}'
						,'$form{'countrynameen'}'
						,'$form{'countrynamecn'}'
						,'$form{'countrynamejp'}'
						,'$form{'countrynametw'}'
						,'1'
						)
				");
				&ExecSQL($q);
			}

			#編集１ ---
			if($form{'edit'} eq "1") {
				@qfld = qw(countryid countrynameen countrynamecn countrynamejp countrynametw);
				$q = "SELECT countryid,countrynameen,countrynamecn,countrynamejp,countrynametw FROM hbjms_countrytb WHERE countryid = '$form{'edtctrid'}' AND countryflg = '1'";
				&ExecSQL($q);
				&GetValueFromSTH(2,"",*qfld);
			#編集２ ---
			} elsif($form{'edit'} eq "2") {
				$q = join("","
					UPDATE hbjms_countrytb
						SET 
							countrynameen	= '$form{'countrynameen'}'
							,countrynamecn	= '$form{'countrynamecn'}'
							,countrynamejp	= '$form{'countrynamejp'}'
							,countrynametw	= '$form{'countrynametw'}'
						WHERE
							countryid	= '$form{'countryid'}'
				");
				&ExecSQL($q);
			}

			#削除 ---
			if($form{'del'} eq "1") {
				$q = join("","
					UPDATE hbjms_countrytb
						SET 
							countryflg	= '0'
						WHERE
							countryid	= '$form{'delctrid'}'
				");
				&ExecSQL($q);
			}

			#国一覧作成 ---
			@qfld = qw(countryid countrynameen countrynamecn countrynamejp countrynametw);
			&ExecSQL("SELECT countryid,countrynameen,countrynamecn,countrynamejp,countrynametw FROM hbjms_countrytb WHERE countryflg = '1'");
			&SetFieldToArray(@qfld);

			for($i = 0; $i <= $#countryid; $i++) {
				$countrytable .= join("","
					<tr>
						<td>$countryid[$i]</td>
						<td>$countrynameen[$i]</td>
						<td>$countrynamecn[$i]</td>
						<td>$countrynamejp[$i]</td>
						<td>$countrynametw[$i]</td>
						<td><a href='$ThisFile?act=mantb\&tb=countrytb\&step=\&edit=1\&edtctrid=$countryid[$i]'>edit</a></td>
						<td><a href='$ThisFile?act=mantb\&tb=countrytb\&step=\&del=1\&delctrid=$countryid[$i]'>delete</a></td>
					</tr>
				");
			}

			if($countrytable ne "") {
				for($i = 0; $i <= $#qfld; $i++) {
					$tbl_h .= "<td $ac>$qfld[$i]</td>";
				}
				$countrytable = "<table border='1' $cp{'2'} $cs{'2'}><tr bgcolor='pink'>$tbl_h<td>edit</td><td>del</td></tr>$countrytable</table><p>";
			} else {
				$countrytable = "txtmantbcountry005<p>";
			}

			#微調節 ---
			if($form{'edit'} eq "1") {
				$regoredit = "edit";
				$regoreditval = "2";
			} else {
				$regoredit = "reg_country";
				$regoreditval = "1";
				$countryid = time;
			}

			$K = join("","

				$countrytable

				txtmantbcountry001
				<table>
				<form action='$ThisFile' method='post'>
				<tr><td>txtmantbcountryid</td><td>_countryid_</td></tr>
				<tr><td>txtmantbcountrynameen</td><td><input type='text' name='countrynameen' value='$countrynameen' size='30'></td></tr>
				<tr><td>txtmantbcountrynamecn</td><td><input type='text' name='countrynamecn' value='$countrynamecn' size='30'></td></tr>
				<tr><td>txtmantbcountrynamejp</td><td><input type='text' name='countrynamejp' value='$countrynamejp' size='30'></td></tr>
				<tr><td>txtmantbcountrynametw</td><td><input type='text' name='countrynametw' value='$countrynametw' size='30'></td></tr>

				<tr><td colspan='2'>
				<input type='submit' value='txtmantbcountry002'>
				<input type='reset' value='txtmantbcountry003'>
				</td></tr>
				<input type='hidden' name='act' value='mantb'>
				<input type='hidden' name='tb' value='countrytb'>
				<input type='hidden' name='$regoredit' value='$regoreditval'>
				<input type='hidden' name='countryid' value='$countryid'>
				</form>
				</table>
			");

		}

	}
}

1;
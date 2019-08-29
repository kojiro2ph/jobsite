
$CR = qq{\\x0D};
$LF = qq{\\x0A};
$VCHAR = qq{[\\x21-\\x7E]};
$WSP = qq{[\\x20\\x09]};

$obs_NO_WS_CTL = qq{[\\x01-\\x08\\x0B\\x0C\\x0E-\\x1F\\x7F]};
$obs_qtext = $obs_NO_WS_CTL;
$obs_qp = qq{(?:\\\\(?:\\x00|$obs_NO_WS_CTL|$LF|$CR))};

$quoted_pair = qq{(?:\\\\(?:$VCHAR|$WSP)|$obs_qp)};

$atext = qq{[A-Za-z0-9!#\$%&'*+\\-/=?^_`{|}~]};
$atom = qq{(?:$atext+)};
$dot_atom_text = qq{(?:$atext+(?:\\.$atext+)*)};
$dot_atom = $dot_atom_text;

$qtext = qq{(?:[\\x21\\x23-\\x5B\\x5D-\\x7E]|$obs_qtext)};
$qcontent = qq{(?:$qtext|$quoted_pair)};
$quoted_string = qq{(?:"$qcontent*")};

$obs_dtext = qq{(?:$obs_NO_WS_CTL|$quoted_pair)};
$dtext = qq{(?:[\\x21-\\x5A\\x5E-\\x7E]|$obs_dtext)};
$domain_literal = qq{(?:\\[$dtext*\\])};

$word = qq{(?:$atom|$quoted_string)};
$obs_local_part = qq{(?:$word(?:\\.$word)*)};
$obs_domain = qq{(?:$atom(?:\\.$atom)*)};
$local_part = qq{(?:$dot_atom|$quoted_string|$obs_local_part)};
$domain = qq{(?:$dot_atom|$domain_literal|$obs_domain)};
$addr_spec = qq{$local_part\@$domain};
$mail_regex = $addr_spec;


sub p0 {

	#テスト ---
	#$qWHERE = $form{'qWHERE'};
	#$sel1 = &MakeSelFromTable("1","hbjms_lngtb","lng","lngid","lngname");

	#登録 ---
	if($form{'step'} eq "reg_e") {
		#メールの正規表現 確認
		$form{'eid'} =~ s/ //g;
		if ($form{'eid'} eq "") {
			push(@errmsg,"<font color='red'><b>_txtp0err03_</b></font>");
		}
		if ($form{'eid'} !~ /^$mail_regex\z/o) {
			push(@errmsg,"<font color='red'><b>_txtp0err01_</b></font>");
		}
		if($form{'eid'} =~ /^[^@]+@[^.]+\..+/){
		} else {
			push(@errmsg,"<font color='red'><b>_txtp0err01_</b></font>");
		}
		#パスワードの確認
		if (length($form{'epwd'}) < 6) {
			push(@errmsg,"<font color='red'><b>_txtp0err02_</b></font>");
		}

		#既に使っているか確認 ---
		$q = "SELECT COUNT(eid) AS cnt FROM hbjms_etb WHERE eid = '$form{'eid'}'";
		&ExecSQL($q);
		$cnt = &GetValueFromSTH(1,"cnt");

		#エラーの場合はココをとばす ---
		if($#errmsg ne -1) {
		} else {

			#存在している ---
			if($cnt > 0) {
				$q = "SELECT COUNT(eid) AS cnt FROM hbjms_etb WHERE eid = '$form{'eid'}' AND epwd = '$form{'epwd'}'";
				&ExecSQL($q);
				$cnt = &GetValueFromSTH(1,"cnt");

				#ログイン成功 ---
				if($cnt > 0) {

					#hbjms_cidmanagetb へ登録 ---
					$q = "INSERT INTO hbjms_cidmanagetb (cid,eid,epwd,regdt,llgndt,cflg) VALUES ('$cid','$form{'eid'}','$form{'epwd'}',NOW(),NOW(),'1')";
					&ExecSQL($q);

					$eid = $form{'eid'};

					$KFULL = "1";
					$K = &Blank(&ConvVal("_txtpleasewait_"),$ThisFile,"2");

					return;
				#ログイン失敗 ---
				} else {

					push(@errmsg,"<font color='red'><b>_txtp0err99_</b></font>");

				}

			} else {
				#登録可能の場合 ---
				if($errmsg eq "") {

					#hbjms_etb へ登録 ---
					$q = "INSERT INTO hbjms_etb (eid,epwd,eregdt,eflg) VALUES ('$form{'eid'}','$form{'epwd'}',NOW(), '1')";
					&ExecSQL($q);

					#hbjms_cidmanagetb へ登録 ---
					$q = "INSERT INTO hbjms_cidmanagetb (cid,eid,epwd,regdt,llgndt,cflg) VALUES ('$cid','$form{'eid'}','$form{'epwd'}',NOW(),NOW(),'1')";
					&ExecSQL($q);


					$KFULL = "1";
					$K = &Blank(&ConvVal("_txtpleasewait_"),$ThisFile,"2");

					return;
				}
			}
		}
	}

	#画面表示 ---
	if($nye eq "1" or $#errmsg ne -1) {

		#エラー文字作成 ---
		for($i = 0; $i <= $#errmsg; $i++) {
			$errmsg .= "[ERR] $errmsg[$i] <br>";
		}
		$errmsg = "<p> $errmsg";


		$K = join("","
			<form action='$ThisFile' method='post'>

			<table width='100%' height='80%'><tr><td $vac $ac>

			<table>
			<tr><td colspan='2'> <font style='font-size: 20pt; font-weight: bold;'>_txtp0topmsg_</font> $errmsg</td></tr>
			<tr><td colspan='2'>\&nbsp;</td></tr>
			<tr><td>_txtdispeid_</td><td><input type='text' name='eid' value='$form{'eid'}' size='20' style='font-size: 30pt; font-weight: bold; font-family: Arial; background-color: #FFFF66;'></td></tr>
			<tr><td colspan='2' $ar><font style='font-size:9pt;' color='red'><b>_txtdispeidalarm_</b></font></td></tr>
			<tr><td colspan='2'>\&nbsp;</td></tr>
			<tr><td>_txtdispepwd_</td><td><input type='password' name='epwd' value='$form{'epwd'}' size='20' style='font-size: 30pt; font-weight: bold; font-family: Arial; background-color: lightblue;'></td></tr>
			<tr><td colspan='2' $ar><font style='font-size:9pt;' color='red'><b>_txtdisppwdalarm_</b></font></td></tr>
			<!--
			<tr><td>_txtdispefname_</td><td><input type='text' name='efname' size='30'></td></tr>
			<tr><td>_txtdispelname_</td><td><input type='text' name='elname' size='30'></td></tr>
			<tr><td>_txtdispeeml_</td><td><input type='text' name='eeml' size='30'></td></tr>
			<tr><td>_txtdispehp_</td><td><input type='text' name='ehp' size='30'></td></tr>
			<tr><td>_txtdispelocate_</td><td><input type='text' name='elocate' size='30'></td></tr>
			-->
			<tr><td colspan='2'>\&nbsp;</td></tr>
			<tr><td colspan='2'>
			<input type='submit' value='_txtdispbtnrege_ ' style='font-size: 16pt; font-weight: bold;'>
			<input type='reset' value='_txtdispbtncancelrege_' style='font-size: 16pt; font-weight: bold;'>
			</td></tr>
			</table>

			</td></tr></table>

			<input type='hidden' name='step' value='reg_e'>
			</form>
		");
		#$K = &ConvVal($K);
	} else {
		#$K = "you are already eid($eid).<br> please go to <a href='$ThisFile?act=menu'>menu</a> page.";

		$KFULL = "1";
		$K = &Blank(&ConvVal("_txtpleasewait_"),"$ThisFile?act=menu","2");

	}


}

1;
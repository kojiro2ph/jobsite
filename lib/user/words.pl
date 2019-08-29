
sub words {

	#言語テーブル取得 ---
	@qfld = qw(lngid lngname);
	&ExecSQL("SELECT lngid,lngname FROM hbjms_lngtb");
	&SetFieldToArray(@qfld);

	#ジャンルテーブル取得 ---
	@qfld = qw(wgid wgnen wgncn wgnjp wgntw);
	&ExecSQL("SELECT wgid,wgnen,wgncn,wgnjp,wgntw FROM hbjms_wgtb");
	&SetFieldToArray(@qfld);


	if($form{'step'} eq "") { $form{'step'} = "w"; }


	#ジャンルの場合 ---
	if($form{'step'} eq "wg") {

		if($form{'substep'} eq "") {

			#登録および編集フラグ変数 ---
			if($form{'reg'} eq "1") {

				if($form{'wgnen'} eq "" and $form{'wgncn'} eq "" and $form{'wgnjp'} eq "" and $form{'wgntw'} eq "") {
					push(@errmsg,"No Input");
				}

				if($#errmsg < 0) {
					$wgid = time;
					$q = join("","INSERT INTO hbjms_wgtb
						(wgid,wgnen,wgncn,wgnjp,wgntw,wgregdt,wgflg)
						VALUES
						('$wgid','$form{'wgnen'}','$form{'wgncn'}','$form{'wgnjp'}','$form{'wgntw'}',NOW(),'1')
					");
					&ExecSQL($q);
				}

				$regoredit = "reg";
				$regoreditval = "1";

			} elsif($form{'edit'} eq "1") {

				@qfld = qw(ewgnen ewgncn ewgnjp ewgntw);
				&ExecSQL("SELECT wgnen AS ewgnen,wgncn AS ewgncn,wgnjp AS ewgnjp,wgntw AS ewgntw FROM hbjms_wgtb WHERE wgid = '$form{'wgid'}'");
				&GetValueFromSTH(2,"",*qfld);

				$regoredit = "edit";
				$regoreditval = "2";

			} elsif($form{'edit'} eq "2") {

				if($form{'wgnen'} eq "" and $form{'wgncn'} eq "" and $form{'wgnjp'} eq "" and $form{'wgntw'} eq "") {
					push(@errmsg,"No Input");
				}

				if($#errmsg < 0) {
					$q = join("","UPDATE hbjms_wgtb SET
						wgnen = '$form{'wgnen'}',
						wgncn = '$form{'wgncn'}',
						wgnjp = '$form{'wgnjp'}',
						wgntw = '$form{'wgntw'}'
						WHERE wgid = '$form{'ewgid'}'
					");
					&ExecSQL($q);
				}

				$regoredit = "reg";
				$regoreditval = "1";

			} else {
				$regoredit = "reg";
				$regoreditval = "1";
			}

			#既存ジャンル一覧作成 ---
			for($i = 0; $i <= $#wgid; $i++) {
				$stri = $i + 1;
				$strtmpwg = ${"wgn" . $lng}[$i];
				$strwglist .= "$stri\. $strtmpwg <a href='$ThisFile?act=words\&step=wg\&edit=1\&wgid=$wgid[$i]'>(edit)</a><br>";
			}

			#ジャンル入力テーブル作成 ---
			for($i = 0; $i <= $#lngid; $i++) {
				$strtmpwg = ${"ewgn" . $lngid[$i]};
				$strwginput .= "<tr><td>$lngname[$i]</td><td><input type='text' name='wgn$lngid[$i]' value='$strtmpwg'></td></tr>";
			}
			$strwginput = "<table border='1'>$strwginput</table>";

			#表示 ---
			$K = join("","

				<table width='90%' $ac><tr><td>

					<font style='font-size:16pt; font-weight: bold;'>_txtwordswg001_</font>
					<p>
					$strwglist
					<p>
					<table>
					<form action='$ThisFile' method='post'>
					$strwginput
					<tr><td colspan='2'>
					<input type='submit' value='ok'>
					<input type='reset' value='cancel'>
					</td></tr>
					<input type='hidden' name='act' value='words'>
					<input type='hidden' name='step' value='wg'>
					<input type='hidden' name='$regoredit' value='$regoreditval'>
					<input type='hidden' name='ewgid' value='$form{'wgid'}'>
					</form>
					</table>

				</td></tr></table>

			");
		}
	# 用語の場合 ---
	} elsif($form{'step'} eq "w") {

		#バッチ登録処理 --- ここから
		if($form{'batchreg'} eq "1") {

			$form{'bw'} =~ s/\r//g;
			@bw = split(/\n/,$form{'bw'});

			$wid = int(time);

			for($i = 1; $i <= $#bw; $i++) {
				#変数整理 ---
				$wid++;
				@lbw = split(/\t/,$bw[$i]);
				$lbw[1] =~ s/\s+$//g;
				$lbw[2] =~ s/\s+$//g;

				#既にあったら登録しない ---
				$q = "SELECT COUNT(wid) AS cnt FROM hbjms_wtb WHERE wnen = '$lbw[1]' AND wgid = '$form{'swgid'}'";
				&ExecSQL($q);
				$cnt = &GetValueFromSTH(1,"cnt");
				if($cnt >= 1) {
					$strq .= "<font style='color: red;'>$q</font>\n";
					next;
				}

				#登録SQL文 ---
				$q = join("","
					INSERT INTO hbjms_wtb
						(wid,wnen,wncn,wgid,wregdt,wflg)
					VALUES
						('$wid','$lbw[1]','$lbw[2]','$form{'swgid'}',NOW(),'1')
				");
				&ExecSQL($q);

				#デバグ用 ---
				$strq .= $q;
			}

		}
		#バッチ登録処理 --- ここまで


		#ジャンル選択エリア ---
		for($i = 0; $i <= $#wgid; $i++) {

			#ジャンルに登録されている用語の数を取得 ---
			$q = "SELECT COUNT(wid) AS cnt FROM hbjms_wtb WHERE wgid = '$wgid[$i]' AND wflg = '1'";
			&ExecSQL($q);
			$cnt = &GetValueFromSTH(1,"cnt");

			$strtmpwg = ${"wgn" . $lng}[$i] . " ($cnt)";

			if($form{'swgid'} eq $wgid[$i]) {
				$aho = "<font style='background-color: #FFFF66; font-weight: bold; Padding: 3pt;'>";
				$ahc = "</font>";
			} else {
				$aho = "<a href='$ThisFile?act=words\&step=w\&swgid=$wgid[$i]'>";
				$ahc = "</a>";
			}
			$strwglist .= "|\&nbsp;\&nbsp;$aho$strtmpwg$ahc\&nbsp;\&nbsp;";
		}
		$strwglist .= "|";

		#ジャンルが選択されていたら ---
		if($form{'swgid'} ne "" or $form{'q'} ne "") {

			#ジャンルの用語を表示する --- (いがいにメイン)
			@qfld = qw(wid wnen wncn wnjp wntw);
			@wid = (); @wnen = (); @wncn = (); @wnjp = (); @wntw = ();
			if($form{'q'} ne "") {
				$form{'q'} =~ s/\s+$//g;
				for($i = 0; $i <= $#lngid; $i++) {
					push(@tmpw,"wn$lngid[$i] LIKE '%$form{'q'}%'");
				}
				$tmpw = "(" . join(" OR ",@tmpw) . ")";
				$q = "SELECT wid,wnen,wncn,wnjp,wntw FROM hbjms_wtb WHERE $tmpw AND wflg = '1'";
				$strq = $q;
				$fs = "14pt";
			} else {
				$q = "SELECT wid,wnen,wncn,wnjp,wntw FROM hbjms_wtb WHERE wgid = '$form{'swgid'}' AND wflg = '1'";
				$fs = "11pt";
			}
			&ExecSQL($q);
			&SetFieldToArray(@qfld);
			for($i = 0; $i <= $#wid; $i++) {
				for($j = 0; $j <= $#lngid; $j++) {
					#この言語の用語が空の場合は自動翻訳して暫時登録をする ---
					if(${"wn" . $lngid[$j]}[$i] eq "") {

						if($lngid[$j] eq "tw") {
							$sp4g = "zh-TW";
						} elsif($lngid[$j] eq "jp") {
							$sp4g = "ja";
						}

						$nama = "1";

						${"wn" . $lngid[$j]}[$i] = &TT("1","",$wncn[$i]);
						$tmpwn = ${"wn" . $lngid[$j]}[$i];

						#暫時登録実行 ---
						$q = "UPDATE hbjms_wtb SET wn$lngid[$j] = '$tmpwn' WHERE wid = '$wid[$i]'";
						&ExecSQL($q);

						$sp4g = "";

					}

					if($form{'q'} ne "") {
						${"wn" . $lngid[$j]}[$i] =~ s/($form{'q'})/<font style='background-color: yellow; padding: 3px;'>$1<\/font>/g;
					}

				}
				$strwlist .= "<tr><td>$wid[$i]\&nbsp;</td><td>$wnen[$i]\&nbsp;</td><td>$wncn[$i]\&nbsp;</td><td>$wnjp[$i]\&nbsp;</td><td>$wntw[$i]\&nbsp;</td></tr>";
			}

			for($i = 0; $i <= $#lngid; $i++) {
				$strwlisth .= "<td $ac>$lngname[$i]</td>";
			}

			if($strwlist eq "") {
				$strwlist = "<i>No Words</i>";
			} else {
				$strwlist = "<table border='1' width='100%' $cp{'5'} $cs{'0'} style='font-size: $fs;'><tr bgcolor='pink'><td $ac>wid</td>$strwlisth</tr>$strwlist</table>";
			}

			#バッチ登録フォームを表示する (管理者のみ) ---
			if($eid eq "kojiro2ph\@yahoo.co.jp") {
				$strbatchreg = join("","
					<b>Batch Registry</b> $#bw
					<table>
					<form action='$ThisFile' method='post'>
					<tr><td>
					<textarea name='bw' rows='20' cols='100'></textarea>
					</td></tr>
					<tr><td>
					<input type='submit' value='ok'>
					<input type='reset' value='cancel'>
					</td></tr>
					<input type='hidden' name='act' value='words'>
					<input type='hidden' name='step' value='w'>
					<input type='hidden' name='batchreg' value='1'>
					<input type='hidden' name='swgid' value='$form{'swgid'}'>
					</form>
					</table>
				");
			}
		}

		$K = join("","
			<table width='90%' $ac><tr><td>

			<table border='0'>
			<form action='$ThisFile' method='post'>
			<tr>
			<td $vam><font style='font-size:16pt; font-weight: bold;'>_txtwordswg001_</font></td>
			<td $vam>
			\&nbsp;\&nbsp;\&nbsp;
			<input type='text' name='q' value='$form{'q'}' style='font-size: 16pt; font-weight: bold; background-color: #FFFF66;'>
			<input type='submit' value='SEARCH'>
			<input type='hidden' name='act' value='words'>
			<input type='hidden' name='step' value='w'>
			</td>
			</tr>
			</form>
			</table>
			<p>
			$strwglist
			<p>
			$strwlist
			<p>
			$strbatchreg


			</td></tr></table>
		");

	}

}

1;
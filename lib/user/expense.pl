
use LWP::Simple;

sub expense {

	if($form{'substep'} eq "") {

		@tb = &GetFileArray(2,"dtf/expense/table");

		for($i = 0; $i <= $#tb; $i++) {
			$tbfname = $tb[$i];
			($tbname,$dum) = $tbfname =~ /(.*)(\.txt)/;
			$tblist .= "<font style='font-size:16pt;'><a href='$ThisFile?act=expense\&tbfname=$tbfname\&substep=tb'>$tbname</a></font> \&nbsp;\&nbsp;";
		}
		$tblist .= join("","
				<p>
				<table><tr><td>
				<form name='FrmNEW' action='$ThisFile' method='POST'>
				<input type='text' name='tbname' size='13' style='font-size: 15pt; font-weight: normal; background-color: lightblue;'>
				<input type='submit' value='new' style='font-size: 13pt;'>
				<input type='hidden' name='act' value='expense'>
				<input type='hidden' name='substep' value='tb'>
				<input type='hidden' name='new' value='1'>
				</form>
				</td></tr><tr><td>
				<form name='FrmIMPORT' action='$ThisFile' method='POST' enctype=\"multipart/form-data\">
				<input type='file' name='impfile' size='13' style='font-size: 15pt; font-weight: normal; background-color: lightgreen;'>
				<input type='submit' value='import' style='font-size: 13pt;'>
				<input type='hidden' name='act' value='expense'>
				<input type='hidden' name='substep' value='tb'>
				<input type='hidden' name='import' value='1'>
				</form>
				</td></tr></table>
		");

		# 出力表示 ---
		$K = join("","
			<table width='100%' height='80%'><tr><td $vac $ac>
			<font style='font-size: 30pt; font-weight: bold;'>_txtheadermenu007_</font>
			<br> <br> <br>
			$tblist
			<p> <p>
			</td></tr></table>
		");

	} elsif($form{'substep'} eq "tb") {

		# ADD TABLE --- START
		if($form{'new'} ne "") {
			if($form{'tbname'} eq "") {
				$form{'tbname'} = "noname";
			}
			$form{'tbfname'} = $form{'tbname'} . ".txt";
			&RecordFileData("dtf/expense/table/$form{'tbfname'}",3,"A,B,C\n" . "txt_30,txt_30,txt_30\n" . "* START *\n");
		}
		# ADD TABLE --- START

		# DEL TABLE --- START
		if($form{'del'} eq "1") {
			&RecordFileData("dtf/bk/expense_table_bk" . time . "_$form{'tbfname'}",3,&ReadFileData("dtf/expense/table/$form{'tbfname'}",3));
			unlink "dtf/expense/table/$form{'tbfname'}";
			$K = &Blank("$form{'tbfname'} has been deleted","$ThisFile?act=expense","2");
			return;
		}
		# DEL TABLE --- END

		# IMPORT TABLE --- START
		if($form{'import'} eq "1") {
			$impfile = $formdata{"impfile_fdata"};
			@impfile = split(/\n/,$impfile);
			for($i = 0; $i <= $#impfile; $i++) {
				if($impfile[$i] =~ /tbfname\=/) {
					($tbfname) = $impfile[$i] =~ /tbfname=(.*\.txt)/;
					last;
				}
			}
			if($tbfname eq "") { $tbfname = "noname.txt"; }
			&RecordFileData("dtf/expense/table/$tbfname",3,$impfile);
			$K = &Blank("$tbfname has been imported !","$ThisFile?act=expense","2");
			return;
		}
		# IMPORT TABLE --- END



		# ADD SHEET --- START
		if($form{'adds'} ne "") {
			&SetTBData;
			&RecordFileData("dtf/expense/table/$form{'tbfname'}",3,"$tbdata\* SHEET$form{'adds'} \*\n");
		}
		# ADD SHEET --- END

		# EDIT COLUM --- START
		if($form{'editcol'} eq "2" or $form{'addcol'} eq "1") {

			&SetTBData;

			if($form{'editcol'} eq "2") {
				$coln[$form{'coln'}] = $form{'newcolname'};
				@tmpct = split(/_/,$colt[$form{'coln'}]);
				$tmpct[0] = "txt";
				$tmpct[1] = $form{'newcolsize'};
				$colt[$form{'coln'}] = join("_",@tmpct);
			} elsif($form{'addcol'} eq "1") {
				@alpha = qw(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
				push(@coln,$alpha[$#coln+1]);
				push(@colt,"txt_30");
				$form{"newcolname"} = "pass";
			}

			$tbh[0] = join(",",@coln);
			$tbh[1] = join(",",@colt);

			$newdata = join("\n",@tbh) . "\n\* START \*\n" . join("\n",@tbb);

			if($form{"newcolname"} eq "") {
			} else {
				&RecordFileData("dtf/expense/table/$form{'tbfname'}",3,"$newdata\n");
			}

		}
		# EDIT COLUM --- END

		# MEMO --- START
		if($form{'memo'} ne "") {
			&SetTBData;
			$curs = $form{'curs'};
			$found = "0";
			for($i = 0; $i <= $#tbh; $i++) {
				if($tbh[$i] =~ /SHEET$curs\MEMO/) {
					$form{'memo'} =~ s/\n/\|NNN\|/g;
					$tbh[$i] = "SHEET$curs" . "MEMO:" . $form{'memo'};
					push(@ntbh,$tbh[$i]);
					$found = "1";
					#push(@kmsg,"hit");
				} elsif($i eq $#tbh and $found eq "0") {
					push(@ntbh,$tbh[$i]);
					push(@ntbh,"SHEET$curs" . "MEMO:" . $form{'memo'});
					#push(@kmsg,"last line");
				} else {
					push(@ntbh,$tbh[$i]);
					#push(@kmsg,"other");
				}
			}
			$newdata = join("\n",@ntbh) . "\n\* START \*\n" . $tbb;
			&RecordFileData("dtf/expense/table/$form{'tbfname'}",3,"$newdata");
		}
		# MEMO --- END

		# DATA ADD --- START
		if($form{'add'} eq "1") {
			&SetTBData;
			for($i = 0; $i <= $#coln; $i++) {
				$tmpd = $form{"col$i"};
				$tmpd =~ s/^\s+//g;
				$tmpd =~ s/\s+$//g;
				push(@adddata,$tmpd);
			}
			$adddata = join(" --- ",@adddata);
			#$kmsg .= $adddata;
			#ADD TO SHEET
			$nexs = $form{'curs'} + 1;
			#$kmsg .= $nexs;
			$tmpm = "\* SHEET$nexs \*";
			#$kmsg .= $#tbb;
			for($i = 0; $i <= $#tbb; $i++) {
				if($tbb[$i] eq "$tmpm") {
					push(@ntbb,$adddata);
					push(@ntbb,$tbb[$i]);
					#$kmsg .= "sheet<br>";
				} elsif($i eq $#tbb) {
					push(@ntbb,$tbb[$i]);
					push(@ntbb,$adddata);
					#$kmsg .= "hit<br>";
				} else {
					push(@ntbb,$tbb[$i]);
					#$kmsg .= "nor<br>";
				}
			}
			if($#tbb eq -1) {
					push(@ntbb,$adddata);
					#$kmsg .= "new data<br>";
			}

			$newdata = $tbh . "\* START \*\n" . join("\n",@ntbb);

			if($form{"col0"} eq "") {
			} else {
				&RecordFileData("dtf/expense/table/$form{'tbfname'}",3,"$newdata\n");
			}
		}
		# DATA ADD --- END

		# DATA EDIT --- START
		if($form{'edit'} eq "2") {
			&SetTBData;

			for($i = 0; $i <= $#coln; $i++) {
				$tmpd = $form{"col$i"};
				$tmpd =~ s/^\s+//g;
				$tmpd =~ s/\s+$//g;
				push(@editdata,$tmpd);
			}
			$editdata = join(" --- ",@editdata);

			$tbb[$form{'ln'}] = $editdata;
			
			$newdata = $tbh . "\* START \*\n" . join("\n",@tbb);

			if($form{"col0"} eq "") {
			} else {
				&RecordFileData("dtf/expense/table/$form{'tbfname'}",3,"$newdata\n");
			}
		} elsif($form{'edit'} eq "3") {
			&SetTBData;

			for($i = 0; $i <= $#tbb; $i++) {
				if($form{'ln'} ne $i) {
					push(@ntbb,$tbb[$i]);
				}
			}

			$newdata = $tbh . "\* START \*\n" . join("\n",@ntbb);
			&RecordFileData("dtf/expense/table/$form{'tbfname'}",3,"$newdata\n");
		}
		# DATA EDIT --- END

		# REPORT --- START
		if($form{'report'} eq "1") {

			&SetTBData;

			# 出力表示 ---
			$K = join("","
				<table width='100%' height='80%'><tr><td $vam $ac>

				<font style='font-size: 26pt; font-weight: bold;'>Report - </font>
				<font style='font-size: 18pt; font-weight: bold;'>$tbname</font>
				<br><br>
				<hr width='60%'>
				<br>
				<font style='font-size: 14pt;'>
				Please click Here
				to <a href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&report=2'><b>Download</b></a> the file and send to Office Manager.<br> <br>
				or <br> <br>
				If you have <font style='font-size: 15pt; font-weight: bold;'>Internet connection</font> then you can click Here to <a href='javascript: void(0);' onClick=\"document.FrmREPORT.submit();\"><b>Report Directly</b></a>.
				</font>
				<p><br>
				<hr width='60%'>

				<form name='FrmREPORT' action='http://www.hamadaboiler.com/jobsite/idx.cgi' method='POST'>
				<input type='hidden' name='act' value='expense'>
				<input type='hidden' name='substep' value='tb'>
				<input type='hidden' name='reportl2s' value='1'>
				<input type='hidden' name='tbfname' value=\"$form{'tbfname'}\">
				<input type='hidden' name='tbdata' value=\"$tbdata4l2s\">
				</form>

				</td></tr></table>

			");

			return;

		} elsif($form{'report'} eq "2") {

			$fn = "HB_" . time . ".txt";
			$fpath = "dtf/expense/table/$form{'tbfname'}";

			print "Content-Type: application/octet-stream;\n";

			#IEとFirefoxの判別 ---
			if($ENV{"HTTP_USER_AGENT"} =~ /MSIE/i) {
				#($fn,$ext) = $fn =~ /(.*)\.(.*)/;
				#$fn = &my_utf8_pe($fn) . "." . $ext;
				print "Content-Disposition: attachment; filename=$fn\n";
			} elsif($ENV{"HTTP_USER_AGENT"} =~ /Firefox/i) {
				print "Content-Disposition: attachment; filename\*=\"UTF-8''$fn\"\n";
			} else {
				print "Content-Disposition: attachment; filename\*=\"UTF-8''$fn\"\n";
			}

			print "\n";

			open(FDL,"$fpath");
			binmode(FDL);
			binmode(STDOUT);
			print <FDL>;
			close(FDL);

			exit(0);

		}
		# REPORT --- END

		# REPORT FROM LOCAL TO SERVER --- START
		if($form{'reportl2s'} eq "1") {
			$form{'tbdata'} =~ s/\|NNN\|/\n/g;
			$form{'tbdata'} =~ s/\|UUU\|/\_/g;
			$form{'tbdata'} =~ s/\|DBC\|/\"/g;
			&RecordFileData("dtf/expense/table/test_$form{'tbfname'}",3,$form{'tbdata'});
			push(@kmsg,"$form{'tbfname'} has been uploaded to server !");
		}
		# REPORT FROM LOCAL TO SERVER --- END


		# CSV --- START
		if($form{'csv'} eq "1") {

			&SetTBData;

			$fn = "HB.csv";
			$fpath = "dtf/expense/table/$form{'tbfname'}";

			print "Content-Type: application/octet-stream;\n";

			#IEとFirefoxの判別 ---
			if($ENV{"HTTP_USER_AGENT"} =~ /MSIE/i) {
				#($fn,$ext) = $fn =~ /(.*)\.(.*)/;
				#$fn = &my_utf8_pe($fn) . "." . $ext;
				print "Content-Disposition: attachment; filename=$fn\n";
			} elsif($ENV{"HTTP_USER_AGENT"} =~ /Firefox/i) {
				print "Content-Disposition: attachment; filename\*=\"UTF-8''$fn\"\n";
			} else {
				print "Content-Disposition: attachment; filename\*=\"UTF-8''$fn\"\n";
			}

			print "\n";

			open(FDL,"$fpath");
			binmode(FDL);
			binmode(STDOUT);
			for($i = 0; $i <= $#tbb; $i++) {
				$tmpd = $tbb[$i];
				@tmpd = split(/ --- /,$tmpd);
				for($j = 0; $j <= $#tmpd; $j++) {
					$tmpd[$j] = "\"$tmpd[$j]\"";
				}
				$tmpd = join(",",@tmpd);
				print "$tmpd\n";
			}
			close(FDL);

			exit(0);
		}
		# CSV --- END







		&SetTBData;

		# Make Table List --- START
		$curs = 1;
		push(@curs,$curs);
		for($i = 0; $i <= $#tbb; $i++) {
			@cold = split(/ --- /,$tbb[$i]);
			if($tbb[$i] =~ /\* SHEET(\d+) \*/) {
				($curs) = $tbb[$i] =~ /\* SHEET(\d+) \*/;
				push(@curs,$curs);
				next;
			} else {
				if($curs eq $form{'curs'}) {
				} else { next; }
			}

			$bgcol = &Parapara("lightgrey");
			$iminus3 = $i - 3;
			if($form{'edit'} eq "1" and $form{'ln'} eq $i) {
				$frmstt = "<form name='FrmEDIT' action='$ThisFile' method='POST'>";
				$frmend = join("","
					<input type='hidden' name='act' value='expense'>
					<input type='hidden' name='substep' value='tb'>
					<input type='hidden' name='tbfname' value='$form{'tbfname'}'>
					<input type='hidden' name='edit' value='2'>
					<input type='hidden' name='ln' value='$form{'ln'}'>
					<input type='hidden' name='curs' value='$form{'curs'}'>
					</form>
				");
				$onmouse = "";
			} else {
				$frmstt = "";
				$frmend = "";
				$onmouse = " onMouseOver=\"this.style.background='#FFCC00'\"  onMouseOut=\"this.style.background='$bgcol'\"";
			}

			$TB .= "<tr bgcolor='$bgcol' onClick=\"location.href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&edit=1\&ln=$i\&curs=$curs#tr$iminus3'\" $onmouse>$frmstt";
			for($j = 0; $j <= $#coln; $j++) {
				if($colt[$j] =~ /ar/) {
					$algn = $ar;
				} else {
					$algn = "";
				}
				if($form{'edit'} eq "1" and $form{'ln'} eq $i) {
					if($colt[$j] =~ /txt_/) {
						@ct = split(/_/,$colt[$j]);
						$inp = "<input type='text' name='col$j' size='$ct[1]' style='font-size: 10pt; font-weight: bold; background-color: lightblue;' value='$cold[$j]'>";
					}
					if($j eq $#coln) {
						$sbm = "<input type='submit' value=' E ' style='font-size: 11pt; font-weight: bold;'> <input type='button' value=' D ' style='font-size: 11pt; font-weight: bold;' onClick=\"document.FrmEDIT.edit.value='3';document.FrmEDIT.submit();\">";
					}
					$TB .= "<td $algn>$inp\&nbsp;$sbm</td>";
				} else {
					if(($form{'ln'}  - 3) eq $i and $j eq 0) {
						#$aname = "<a name='tr$i'>\&nbsp;</a>";
					} else {
						$aname = "";
					}
					$TB .= "<td $algn>$aname$cold[$j]</td>";
				}
				if($colt[$j] =~ /cnt/) {
					$tmpn = $cold[$j];
					$tmpn =~ s/,//g;
					$coltt[$j] = $coltt[$j] + $tmpn;
				}
			}
			$TB .= "$frmend</tr>\n";
		}

		# Table Header
		for($i = 0; $i <= $#coln; $i++) {
			if($form{'editcol'} eq "1" and $form{'coln'} eq $i) {
				@ct = split(/_/,$colt[$i]);
				$TBH .= join("","
					<form name='FrmEDITCOL' action='$ThisFile' method='POST'>
					<td $ac bgcolor='pink'>
					<input type='text' name='newcolname' size='10' style='font-size: 10pt; font-weight: bold; background-color: lightgreen;' value='$coln[$i]'>
					<b>size:</b> <input type='text' name='newcolsize' size='1' style='font-size: 8pt; font-weight: bold; background-color: lightgreen;' value='$ct[1]'>
					<input type='submit' value='save' style='font-size: 8pt; font-weight: bold;'>
					</td>
					<input type='hidden' name='act' value='expense'>
					<input type='hidden' name='substep' value='tb'>
					<input type='hidden' name='tbfname' value='$form{'tbfname'}'>
					<input type='hidden' name='editcol' value='2'>
					<input type='hidden' name='coln' value='$form{'coln'}'>
					<input type='hidden' name='curs' value='$form{'curs'}'>
					</form>
				");
			} else {
				if($i eq $#coln) {
					$tmpcoln = "<table width='100%'></tr><td width='90%' $ac><b>$coln[$i]</b></td><td width='90%' $ar><b><a href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&addcol=1\&curs=$form{'curs'}'>+</a></b></td></tr></table>";
				} else {
					$tmpcoln = "<b>$coln[$i]</b>";
				}
				$TBH .= "<td $ac onClick=\"location.href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&editcol=1\&coln=$i\&curs=$form{'curs'}'\"  onMouseOver=\"this.style.background='#FFCC00'\"  onMouseOut=\"this.style.background='pink'\">$tmpcoln</td>";
			}
		}
		# Table Footer
		for($i = 0; $i <= $#coln; $i++) {
			if($colt[$i] =~ /txt_/) {
				@ct = split(/_/,$colt[$i]);
				$inp = "<input type='text' name='col$i' size='$ct[1]' style='font-size: 10pt; font-weight: bold; background-color: lightgreen;'>";
			}
			if($i eq $#coln) {
				$sbm = "<input type='submit' value='ADD' style='font-size: 11pt; font-weight: bold;'>";
			} else {
				$sbm = "";
			}
			$TBF1 .= "<td>$inp\&nbsp;$sbm</td>";
		}
		for($i = 0; $i <= $#coln; $i++) {
			if($coltt[$i] eq "") {
				$coltt[$i] = "\&nbsp;";
			} else {
				$coltt[$i] = &ConvPriceComma($coltt[$i]);
				if($coltt[$i] =~ /\./) {
					@tmpnum = split(/\./,$coltt[$i]);
					if(length($tmpnum[1]) eq 1) {
						$tmpnum[1] .= "0";
					}
					$coltt[$i] = $tmpnum[0] . "." . $tmpnum[1];
				} else {
					$coltt[$i] .= "\.00";
				}
			}
			$TBF2 .= "<td $ar bgcolor='#FFFFFF'><font style='font-size: 28pt; font-weight: bold;'>$coltt[$i]</font></td>";
	
		}

		$TBH = "<tr bgcolor='pink'>$TBH</tr>";
		$TBF1 = join("","
			<tr><form name='FrmADD' action='$ThisFile' method='POST'>
			$TBF1
			<input type='hidden' name='act' value='expense'>
			<input type='hidden' name='substep' value='tb'>
			<input type='hidden' name='tbfname' value='$form{'tbfname'}'>
			<input type='hidden' name='add' value='1'>
			<input type='hidden' name='curs' value='$form{'curs'}'>
			</form></tr>
			");

		$colspan = $#coln + 1;
		$strMEMO = ${"SHEET$form{'curs'}" .  "MEMO"};
		if($strMEMO eq "") { $strMEMO = "MEMO"; }
		if($form{'editmemo'} eq "1") {
			$MEMO = join("","
				<tr><form name='FrmMEMO' action='$ThisFile' method='POST'>
				<td colspan='$colspan' $ar>
				<textarea name='memo' rows='10' cols='30' style='font-size:16pt; font-weight: bold;'>$strMEMO</textarea> <br> <input type='submit' value='MEMO'>
				</td>
				<input type='hidden' name='act' value='expense'>
				<input type='hidden' name='substep' value='tb'>
				<input type='hidden' name='tbfname' value='$form{'tbfname'}'>
				<input type='hidden' name='curs' value='$form{'curs'}'>
				</form>
				</tr>");
		} else {
			$strMEMO =~ s/\n/<br>/g;
			$MEMO = join("","
				<tr>
				<td colspan='$colspan' $ar bgcolor=\"#FFFFFF\" onClick=\"location.href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&editmemo=1\&curs=$form{'curs'}'\"  onMouseOver=\"this.style.background='#FFCC00'\"  onMouseOut=\"this.style.background='#FFFFFF'\">
					<font style='font-size:28pt; font-weight: bold;'>
					$strMEMO
					</font>
				</td>
				</tr>");
		}
		$TBF2 = "<tr>$TBF2</tr>$MEMO";
		$TB4PRINT =  "<table border='0' $cp{'5'} $cs{'1'} style='font-size:9pt;' bgcolor='black'>$TBH$TB$TBF2</table>";
		$TB = "<table border='0' $cp{'5'} $cs{'1'} style='font-size:12pt;'>$TBH$TBF1$TB$TBF2</table>";
		# Make Table List --- END

		#Sheet Info --- START
		for($i = 0; $i <= $#curs; $i++) {
			if($form{'curs'} eq $curs[$i]) {
				$sheetinfo .= "<font style='font-size: 13pt; font-weight: bold;'><i>$curs[$i]</i></font> ";
			} else {
				$sheetinfo .= "<a href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&curs=$curs[$i]'>$curs[$i]</a> ";
			}
		}
		$adds = $curs[$#curs] + 1;
		$sheetinfo = "[ Sheet: $sheetinfo <a href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&adds=$adds\&curs=$adds'><i>new sheet</i></a> ] ";
		#Sheet Info --- END

		# tbfname or rename mode
		if($form{'rename'} eq "1") {
			$lbl = join("","
				<form name='FrmMEMO' action='$ThisFile' method='POST'>
				<input type='text' name='rtbname' size='20' style='font-size:16pt; font-weight: bold; background-color: lightblue;' value='$tbname'>
				<input type='submit' value='rename'>
				<input type='hidden' name='act' value='expense'>
				<input type='hidden' name='substep' value='tb'>
				<input type='hidden' name='tbfname' value='$form{'tbfname'}'>
				<input type='hidden' name='rename' value='2'>
				<input type='hidden' name='curs' value='$form{'curs'}'>
				</form>
			");
		} else {
			$lbl = "<table $cp{'3'} $cs{'10'}><tr><td onMouseOver=\"this.style.background='#FFCC00'\" onMouseOut=\"this.style.background='#FFFFFF'\" onClick=\"javascript: location.href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&rename=1\&curs=$form{'curs'}'\"><font style='font-size: 18pt; font-weight: bold;'>$tbname</font></td></tr></table>";
		}


		# kmsg 作成 ---
		for($i = 0; $i <= $#kmsg; $i++) {
			$kmsg .= "<font style='font-size: 16pt; font-weight: bold; color: #FF0000;'>$kmsg[$i]</font> <br>";
		}

		# 出力表示 ---
		$K = join("","
			<table width='100%' height='80%'><tr><td $vat $ac>
			$lbl
			<p>
			<a href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&report=1'><b>REPORT</b></a> - 
			<a href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&csv=1'><b>EXCEL</b></a> - 
			$sheetinfo - 
			<a href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&curs=$form{'curs'}\&print=1' target='_myself'><b>PRINT</b></a> - 
			<a href='$ThisFile?act=expense\&substep=tb\&tbfname=$form{'tbfname'}\&del=1' target='_myself'><b>DEL</b></a>
			<p>
			$kmsg
			<p>
			$TB
			</td></tr></table>
		");

		# PRINT --- START
		if($form{'print'} eq "1") {
			$K = join("","
				<table width='100%' height='80%'><tr><td $vat $ac>
				<font style='font-size: 18pt; font-weight: bold;'>$tbname</font> Sheet $form{'curs'} - <a href='javascript: window.close();'>close</a>
				<p>
				$TB4PRINT
				</td></tr></table>
			");
		}
		# PRINT --- END

		$onLoad = "onLoad=\"document.FrmADD.col0.focus();\"";
	}




}

sub SetTBData {
	if($form{'rename'} eq "2") {
		rename("dtf/expense/table/$form{'tbfname'}","dtf/expense/table/$form{'rtbname'}\.txt");
		push(@kmsg,"$form{'tbfname'} has been renamed to $form{'rtbname'}\.txt");
		$form{'rename'} = "";
		$form{'tbfname'} = $form{'rtbname'} . "\.txt";
	}
	($tbname,$dum) = $form{'tbfname'} =~ /(.*)(\.txt)/;
	$tbdata = &ReadFileData("dtf/expense/table/$form{'tbfname'}",3);
	$tbdata4l2s = $tbdata;
	$tbdata4l2s =~ s/\"/\|DBC\|/g;
	$tbdata4l2s =~ s/\n/\|NNN\|/g;
	$tbdata4l2s =~ s/\_/\|UUU\|/g;
	($tbdata4l2s) = $tbdata4l2s =~ /.(.*)/;
	($tbh,$tbb) = split(/\* START \*\n/,$tbdata);
	@tbh = split(/\n/,$tbh);
	@tbb = split(/\n/,$tbb);
	@coln = split(/,/,$tbh[0]);
	@colt = split(/,/,$tbh[1]);
	for($i = 0; $i <= $#tbh; $i++) {
		if($tbh[$i] =~ /SHEET(\d+)MEMO/) {
			($memoi) = $tbh[$i] =~ /SHEET(\d+)MEMO/;
			($dum,${"SHEET$memoi" . "MEMO"}) = $tbh[$i] =~ /SHEET(\d+)MEMO\:(.*)/;
			${"SHEET$memoi" . "MEMO"} =~ s/\|NNN\|/\n/g;
		}
	}

	# CHECK DATA --- START
	# (tbfname line)
	$found = "0";
	for($i = 0; $i <= $#tbh; $i++) {
		if($tbh[$i] =~ /tbfname\=/) {
			if($tbh[$i] eq "tbfname\=$form{'tbfname'}") {
				$found = "1";
			} else {
				$tbh[$i] = "tbfname\=$form{'tbfname'}";
				$update = "1";
				$found = "0";
			}
			last;
		}
	}
	if($found eq "1") {
	} else {
		if($update eq "1") {
		} else {
			push(@tbh,"tbfname=$form{'tbfname'}");
		}
		$newdata = join("\n",@tbh) . "\n\* START \*\n" . join("\n",@tbb);
		&RecordFileData("dtf/expense/table/$form{'tbfname'}",3,"$newdata\n");
		&SetTBData;
	}
	# CHECK DATA --- END

	if($form{'curs'} eq "") { $form{'curs'} = "1"; }
}

1;
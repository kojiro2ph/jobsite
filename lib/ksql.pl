#
#
#
#
#
#
#
#
#


########################################
#	ＳＱＬ環境を初期化する
########################################

sub Init_SQL {

	print &PH;
	print "dsfdafd";
	exit(0);



	if($ENV{'HTTP_HOST'} eq "www.gurume.net") {
		$mysql_host	= "www.gurume.net";
		$mysql_user	= "gurumene";
		$mysql_pass	= "mmNp7mj7";
	}
	elsif($ENV{'HTTP_HOST'} eq "www.opengate1.com") {
		$mysql_host	= "www.opengate1.com";
		$mysql_user	= "gurumene";
		$mysql_pass	= "mmNp7mj7";
	}
	elsif($ENV{'HTTP_HOST'} =~ /gold/) {
		$mysql_host	= "ftp.goldweb.cx";
		$mysql_user	= "gurume";
		$mysql_pass	= "RDhdHf48";
	}
	else {
		$mysql_host	= "localhost";
		$mysql_user	= "root";
		$mysql_pass	= "koji410";
	}

}



########################################
#	ＳＱＬに接続する
########################################
sub ConnectSQL {
	local($driver,$database,$hostname,$port,$user,$password) = @_;
	local($dsn);

 	$dsn = "DBI:$driver:database=$database;host=$hostname;port=$port"; #ＤＳＮ変数初期化
	$dbh = DBI->connect($dsn, $user, $password);	#接続実行
	print "$dbh->errstr" if(not $dbh);
	$drh = DBI->install_driver("mysql");	#ドライバインストール
	print "$dbh->errstr" if(not $dbh);


}


########################################
#	ＳＱＬを切断する
########################################
sub DisconnectSQL {

	$dbh->disconnect();	# 切断実行


}


########################################
#	sthをTABLE化にする
########################################

sub MakeTableFromSTH {
	local($tname) = @_;
	local($i,$strline,$numRows,$numFields,@field);

	#フィールド名をヘッドに挿入
	&ExecSQL("DESC $tname"); #ＳＱＬ文実行
	@fldname = &MakeArrayBySpecCat("Field");

	for($i = 0; $i <= $#fldname; $i++) {

		if($fldname[$i] eq "") {
			$fldname[$i] = "\&nbsp;";
		}
		$strline .= "<td><b>$fldname[$i]</b></td>\n";
	}

	$strline = "<tr bgcolor=\"pink\">\n$strline</tr>\n";



	&ExecSQL("SELECT * from $tname"); #ＳＱＬ文実行
	$numRows 	= $sth->rows;			#行数
	$numFields 	= $sth->{'NUM_OF_FIELDS'};	#項目数

	#項目に対するバインドをする
	for($i = 1; $i <= $numFields; $i++) {
		$sth->bind_col($i, \$field[$i], undef);
	}


	#メインテーブルを作成する
	while ( $sth->fetch ){
		$strline .= "<tr>\n";
		for($i = 1; $i <= $#field; $i++) {
			if($field[$i] eq "") {
				$field[$i] = "\&nbsp;";
			}
			$field[$i] = &ConvHTMLTag($field[$i]);
			$strline .= "<td nowrap>$field[$i]</td>\n";
		}
		$strline .= "</tr>\n";
	} 


	#テーブル整理
	$strline = join("","
		<table style=\"font-size:10pt\" border=\"1\">
		$strline
		</table>
		");

	return $strline;
}

########################################
#	ＳＱＬ実行
########################################

sub ExecSQL {
	local($cmd) = @_;	

	$sth = $dbh->prepare($cmd);
	$sth->execute();

}

########################################
#	指定フィールドを配列に入れる
########################################

sub MakeArrayBySpecCat {
	local($name) = @_;
	local(@strarray);

	while ($ref = $sth->fetchrow_hashref()) {
		#push(@strarray,$ref->{$name});
		push(@strarray,decode('utf8',$ref->{$name}));
	}

	return @strarray;

}

########################################
#	ファイルtoテーブル
########################################

sub MakeTableFromCSVFile {
	local($fname,$tname) = @_;
	local($i,$fdata,$fldstat,$query,$fld,@fdataarray,@fldstatarray);

	$fld = "";
#print "<HR>";

	#ファイル読み込み（タブ区切り）
	$fdata = &JE(&ReadFileData("$fname",3));
	@fdataarray = split(/\n/,$fdata);
#print "<HR>";

	#一行目を取り除く
	shift(@fdataarray);
	$fldstat = shift(@fdataarray);

	#項目処理
	$fldstat =~ s/\t/,/g;
	@fldstatarray = split(/,/,$fldstat);



	#テーブル作成  --------------ここから
	for($i = 0; $i <= $#fldstatarray; $i++) {

		$fldname 	= "";
		$fldtype 	= "";
		$typename 	= "";
		$typebyte 	= "";

		($fldname,$fldtype) = split(/_/,$fldstatarray[$i],2);
		($typename,$typebyte) = split(/:/,$fldtype,2);


		$typename =~ s/vc/VARCHAR/g;
		$typename =~ s/txt/TEXT/g;
		$typename =~ s/dt/DATE/g;
		$typename =~ s/int/INT/g;


		if($typename eq "VARCHAR") {
			$fldtype = "$typename\($typebyte\)";
		} else {
			$fldtype = "$typename";
		}
		
		$query .= "$fldname $fldtype,";
		$fld .= "$fldname,";
	}

	chop($query);
	chop($fld);

#print "CREATE TABLE $tname($query)<HR>";
#exit(0);

	$sth = $dbh->prepare("CREATE TABLE $tname($query)");
	$sth->execute();



	#print "CREATE TABLE $tname($query)";


	#行ごとのＩＮＳＥＲＴループ --------------ここから
	for($i = 0; $i <= $#fdataarray; $i++) {
		$query = "";

		if($fdataarray[$i] eq "") {
			next;
		}

		@tmp = split(/\t/,$fdataarray[$i],$#fldstatarray + 1);



		for($j = 0; $j <= $#tmp; $j++) {
			$tmp[$j] =~ s/_T_/\t/g;
			$tmp[$j] =~ s/_N_/\n/g;
			$query .= "'$tmp[$j]',";
		}

		chop($query);

		#print "<font =\"2\"><b>$i</b>$query</font><br>\n";
		#print "$i INSERT INTO $tname($fld) VALUES ($query)<br>\n";


		$sth = $dbh->prepare("INSERT INTO $tname($fld) VALUES ($query)");
		$sth->execute();

	}
}


########################################
#指定テーブルから指定キーの指定項目を取得する
########################################

sub MakeCSVFileFromTable {
	local($fname,$tname) = @_;
	local($i,$numRows,$numFields,$fldtype,$fldbyte,$fldlabel,$strline,@field,@fldname,@fldtype,@tmparray);

	#フィールド名をヘッドに挿入
	&ExecSQL("DESC $tname"); #ＳＱＬ文実行
	@fldname = &MakeArrayBySpecCat("Field");

	&ExecSQL("DESC $tname");
	@fldtype = &MakeArrayBySpecCat("Type");


	for($i = 0; $i <= $#fldname; $i++) {

		if($fldname[$i] eq "") {
			$fldname[$i] = "\&nbsp;";
		}

		$fldtype = &GetFieldType(1,$tname,$fldname[$i]);

		# VARCHAR の場合
		if(($fldtype =~ /^varchar/)) {
			$fldtype =~ /varchar\((.*)\)/;
			$fldbyte = $1;
			$fldlabel = "$fldname[$i]_vc:$fldbyte";
		}
		#CAHR の場合
		if(($fldtype =~ /^char/)) {
			$fldtype =~ /char\((.*)\)/;
			$fldbyte = $1;
			$fldlabel = "$fldname[$i]_vc:$fldbyte";
		}
		# TEXTの場合
		elsif($fldtype =~ /^text/) {
			$fldlabel = "$fldname[$i]_txt";
		# DATEの場合
		}
		elsif($fldtype =~ /^date/) {
			$fldlabel = "$fldname[$i]_dt";
		# INTの場合
		}
		elsif($fldtype =~ /^int/) {
			$fldlabel = "$fldname[$i]_int";
		}

		push(@tmparray,$fldlabel);
	}

	@tmparray = &SortInOne(@tmparray);
	$strline .= (join("\t",@tmparray) . "\n") x 2;


	@tmparray = ();

	&ExecSQL("SELECT * from $tname"); #ＳＱＬ文実行
	$numRows 	= $sth->rows;			#行数
	$numFields 	= $sth->{'NUM_OF_FIELDS'};	#項目数

	#項目に対するバインドをする
	for($i = 1; $i <= $numFields; $i++) {
		$sth->bind_col($i, \$field[$i], undef);
	}


	#メインテーブルを作成する
	while ( $sth->fetch ){

		for($i = 1; $i <= $#field; $i++) {
			#if($field[$i] eq "") {
			#	$field[$i] = "\&nbsp;";
			#}
			#$field[$i] = &ConvHTMLTag($field[$i]);
			$field[$i] =~ s/\r//g;
			$field[$i] =~ s/\n/_N_/g;
			$field[$i] =~ s/\t/_T_/g;
			push(@tmparray,&JE($field[$i]));
		}
		$strline = $strline . join("\t",@tmparray);
		$strline = $strline . "\n";
		@tmparray = ();

		print "|";
		$len = length($strline);

		if($br++ % 100 eq 0) {
			print " $len<BR>\n";
		}


		if($len > 30000) {
			&RecordFileData($fname,4,$strline);
			$strline = "";
		}

	} 


	#ファイル書き込み
	&RecordFileData($fname,4,$strline);

	return $strline;


}


########################################
#指定テーブルから指定キーの指定項目を取得する
########################################

sub GetSpecFieldBySpecKeyFromSpecTable {
	local($mode,$tname,$key_fldname,$key_fldvalue,$fldname) = @_;

	if($mode eq 1) {
		&ExecSQL("SELECT $fldname FROM $tname WHERE $key_fldname = '$key_fldvalue'");

		#変数格納
		$ref = $sth->fetchrow_hashref();
		$strtmp = $ref->{$fldname};
		$rc = $sth->finish;


		return $strtmp;
	}


}

########################################
# 指定項目のフィールドタイプを取得する
########################################

sub GetFieldType {
	local($mode,$tname,$fldname) = @_;
	local($i);

	if($mode eq 1) {
		&ExecSQL("DESC $tname");
		@fldname = &MakeArrayBySpecCat("Field");
		&ExecSQL("DESC $tname");
		@fldtype = &MakeArrayBySpecCat("Type");

		for($i = 0; $i <= $#fldname; $i++) {
			if($fldname[$i] eq $fldname) {
				return $fldtype[$i];
			}
		}

		return "0";
	}
}

########################################
# 指定フィールドタイプからバイト数を取得する
########################################

sub GetByteFromFieldType {
	local($fldtype) = @_;

	if($fldtype =~ /varchar/) {
		$fldtype =~ /varchar\((.*)\)/;
		$strtmp = $1;
	}
	elsif($fldtype =~ /text/) {
		$strtmp = 5000;
	}

	return $strtmp;
}

########################################
# 連想配列を SET 文字列にする（フィルターつき）
########################################

sub MakeStrSETFromHashWithFilter {
	local($mode,*remove,*hash) = @_;
	local($k,$v);

	while(($k,$v) = each %hash) {
		if(&StringMatchToArray($k,@remove) eq "0") {
			$strtmp .= " $k = '$v',";
		}
	}

	chop($strtmp);

	$strtmp = "SET $strtmp";


	return $strtmp;
}


########################################
# 行数を取得する
########################################

sub GetRows {
	local($q) = @_;
	local($strtmp);

	&ExecSQL($q);
	$strtmp = $sth->rows;
	$rc = $sth->finish;

	return $strtmp;
}


########################################
# 項目ごとを配列化する
########################################

sub SetFieldToArray {
	local(@strarray) = @_;
	local($TMP);

	while ($ref = $sth->fetchrow_hashref()) {
		foreach $TMP (@strarray) {
			push(@{$TMP},decode('utf8',$ref->{$TMP}));
		}
	}
}

########################################
# バイト数を超えてないか確認
########################################

sub IsOverString {
	local($tname) = @_;

	#フィールド名をヘッドに挿入
	&ExecSQL("DESC $tname"); #ＳＱＬ文実行
	@fldname = &MakeArrayBySpecCat("Field");
		
	for($i = 0; $i <= $#fldname; $i++) {
		if(length($form{"$fldname[$i]"}) > &GetByteFromFieldType(&GetFieldType(1,$tname,$fldname[$i]))) {
			$pOverString = $fldname[$i];
			return 1;
		}
	}

	return 0;
}

########################################
# sth から指定項目の値を取得
########################################

sub GetValueFromSTH {
	local($mode,$q,*strarray,*hash) = @_;
	local($strtmp);

	if($mode eq 1) {
		$ref = $sth->fetchrow_hashref();
		#$strtmp = &JE($ref->{$q});
		$strtmp = decode('utf8',$ref->{$q});
		$rc = $sth->finish;

		return $strtmp;
	} elsif($mode eq 2) {
		$ref = $sth->fetchrow_hashref();
		foreach $tmp (@strarray) {
			${$tmp} = decode('utf8',$ref->{$tmp});
		}
		$rc = $sth->finish;		
	} elsif($mode eq 3) {
		$ref = $sth->fetchrow_hashref();
		foreach $tmp (@strarray) {
			$hash{$tmp} = &JE($ref->{$tmp});
		}
		$rc = $sth->finish;		
	}
}

########################################
# form 変数を指定テーブルに登録
########################################

sub InsertFromHash {
	local($tname,*hash) = @_;
	local($q,$TMP,$StrSET,@qfld);

	#INSERT文作成
	&ExecSQL("DESC $tname");
	@qfld = &MakeArrayBySpecCat("Field");

	foreach $TMP (@qfld) {
		$StrSET .= "$TMP = \'$hash{$TMP}\',";
	}
	chop($StrSET);

	$q = join("","
		INSERT INTO $tname SET 
			$StrSET
		");


	#登録実行 --------------- ここから
	&ExecSQL($q);
}


########################################
#  指定テーブルから指定項目を出力する
########################################

sub ViewFldFromTable {

		print &PH;
		print &PrintMETA("euc");
		print "<pre>";


		&ExecSQL("DESC $form{'tname'}");
		@fld = &MakeArrayBySpecCat("Field");


		if($form{'fldname'} eq "*") {
			$form{'fldname'} = join(":",@fld);
		}


		@qfld = split(/:/,$form{'fldname'});
		$fldname = join(",",@qfld);


		foreach(@qfld) {
			$_ = substr($_,0,8);
		}
		$strtmp = join("\t",@qfld);
		print "$strtmp\n";




		&ExecSQL("SELECT $fldname from $form{'tname'}");
		&SetFieldToArray(@qfld);




		for($i = 0; $i <= $#{$qfld[0]}; $i++) {
			@strarray = ();

			foreach(@qfld) {
				${$_}[$i] = " " if(${$_}[$i] eq "");
				push(@strarray,substr(${$_}[$i],0,8));
			}

			$strtmp = join("\t",@strarray);
			print "$strtmp\n";

		}


		#print &ListArray(1,@{$form{'fldname'}});
		print "</pre>";
		exit(0);


}


sub InitHashFromTable {
	local($mode,$tname,$pk,$pv) = @_;
	local($i,@s1,@s2,%hash);

	if($mode eq 1) {
		&ExecSQL("SELECT $pk from $tname");

		@s1= &MakeArrayBySpecCat($pk);

		&ExecSQL("SELECT $pv from $tname");
		@s2 = &MakeArrayBySpecCat($pv);

		for($i = 0;$i <= $#s1; $i++) {
			$hash{$s1[$i]} = $s2[$i];
		}

		return %hash;

	}

}


1;
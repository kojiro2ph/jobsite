
sub report {

	#ログイン近況表示 --- ここから
	@qfld = qw(eid llgndt);
	$q = "SELECT eid,llgndt FROM hbjms_cidmanagetb ORDER BY llgndt DESC";
	&ExecSQL($q);
	&SetFieldToArray(@qfld);

	for($i = 0; $i <= $#eid; $i++) {
		if(&StringMatchToArray($eid[$i],@showedeid) ne 1) {

			#コラムの色　セット ---
			$tmpcol = &Parapara("#EFE8EF");

			if($cnt++ <= 4) {
				$tmpcol = "#FFD700";
			}

			$llgntable .= "<tr bgcolor='$tmpcol'><td>$eid[$i]</td><td>$llgndt[$i]</tr>";
			push(@showedeid,$eid[$i]);
		}
	}
	$llgntable = "<table border='0' $cp{'5'} $cs{'3'}><tr bgcolor='pink'><td colspan='2' $ac>Login Status</td></tr>$llgntable</table>";
	#ログイン近況表示 --- ここまで


	$K = join("","
		<table width='100%' height='80%'><tr><td $vac $ac>

		<p> <p>

		$llgntable

		</td></tr></table>
	");

}

1;
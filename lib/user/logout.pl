
sub logout {

	print &PutCookie("HBJMS","cid:",90);

	$KFULL = "1";

	$K = &Blank(&ConvVal("_txtpleasewait_"),$ThisFile,"2");

	$K = &ConvVal($K);

}

1;
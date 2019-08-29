#!/usr/local/bin/perl

use DBI;
#use encoding 'utf8';
#use utf8;

use Encode::Guess qw/ shiftjis euc-jp 7bit-jis iso-8859-2 /;
use Encode qw/ decode /;
use Encode qw/  encode /;
use MIME::Base64;

binmode STDIN,  ":utf8";
binmode STDOUT, ":utf8";

#=================================================[init routine]====

#global variable ---
$StdLib 		= "lib/kstd.pl";
$SqlLib 		= "lib/ksql.pl";
$JcodeLib 		= "lib/jcode.pl";
$MimewLib		= "lib/mimew.pl";
$HLib			= "lib/hlib.pl";
$ThisFile		= $ENV{"SCRIPT_NAME"};
$MainINIFile	= "ini/idx.ini";

#---------------------------------------------------------------------

$|=1;

require "$StdLib";			#original library
require "$SqlLib";			#sql library
require "$JcodeLib";			#jcode library
require "$MimewLib";			#mime library
require "$HLib";			#h library

&Init_Form("euc");
&Init_Tag;

%INI = {};
%INI = &InitINIData(1,$MainINIFile);

#==================================================================================[main routine]====
#----------------------------------------------------------------------------------------------------
#====================================================================================================

&Init_System;
&Run;
&PB;

#print "Content-Type: text/html\n\n";
#print "<HTML><HEAD><TITLE>a</TITLE></HEAD><BODY>b</BODY></HTML>";


exit(0);

#====================================================================================[sub routine]===
#----------------------------------------------------------------------------------------------------
#====================================================================================================

#====================================================================================[library]=======
#----------------------------------------------------------------------------------------------------
#====================================================================================================

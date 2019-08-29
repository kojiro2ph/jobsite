#!/usr/bin/perl
# envrep - environment report
print "Content-Type: text/html\n\n";
foreach $vn(sort keys %ENV) {
 print "$vn = $ENV{$vn}<br>";
}
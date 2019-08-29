#!/usr/bin/perl
use strict;
use warnings;
use Image::ExifTool;

my $file = "taiwan/clc/tayuan/tp_1242977240.jpg";
my $exifTool = new Image::ExifTool;
my $info = $exifTool->ImageInfo($file);

print "Content-Type: text/html\n\n";

foreach (sort keys %$info) {
  print "$_ => $$info{$_}\n";
}

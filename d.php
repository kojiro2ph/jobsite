<?php
$img = ImageCreate(100,100);

$black = ImageColorAllocate($img, 0x00, 0x00, 0x00);
ImageFilledRectangle($img, 0,0, 100,100, $black);

$white = ImageColorAllocate($img, 0xff, 0xff, 0xff);
ImageFilledRectangle($img, 20,20, 60,60, $white);

header('Content-Type: image/png');
ImagePNG($img);
?>

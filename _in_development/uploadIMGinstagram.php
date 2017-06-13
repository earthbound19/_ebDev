<?php

// DESCRIPTION
// uses the reverse-engineered (!) Instagram API to upload an image to your instagram account. re: https://github.com/mgp25/Instagram-API

// USAGE
// Invoke this script with the following parameters, being:
// $argv[1] : your Instagram username
// $argv[2] : " password
// $argv[3] : image file name (with path if necessary, if that will even work) to upload to your Instagram account.
// $argv[4] : caption text for image (surrounded by double quote marks).

// DEV NOTES
// How did I install this? cakePHP was it?

set_time_limit(0);
date_default_timezone_set('UTC');

		// DEV TESTING: print current directory, then exit.
		echo "flarf\n";
		echo getcwd() . "\n";
		echo "flarfor\n";
		echo __DIR__;

// require __DIR__.'vendor/autoload.php';
require 'vendor/autoload.php';
		exit(0);

/////// CONFIG ///////
$username = $argv[1];
$password = $argv[2];
	// FOR TESTING:
	echo 'password assumed from argv 1 is: ';
	echo $password;
	exit(0);
$debug = true;
$truncatedDebug = false;
//////////////////////

/////// MEDIA ////////
// Max. image dimensions 1080x1080 according to https://colorlib.com/wp/size-of-the-instagram-picture -- unsure whether that means longest any image can be on one or both sides is 1080; I assume so.
// You can share photos and videos with aspect ratios between 1.91:1 (the width almost two times the height, decimal 0.52356 = 1/1.91) and 4:5 (square with a fair amount of trim off sides, decimal 0.8 = 4/5) re: https://help.instagram.com/1469029763400082 but they may appear to users as a center-cropped square.
// You will need to point your php.ini to a valid cert file (get one if you don't have one) e.g.:
// openssl.cafile="C:\PHP\cacert.pem"
// also install this stuff by running:
// composer require mgp25/instagram-php
// --from the root of this cloned repo.

$photoFilename = $argv[3];
$captionText = $argv[4];
//////////////////////

$ig = new \InstagramAPI\Instagram($debug, $truncatedDebug);

try {
    $ig->setUser($username, $password);
    $ig->login();
} catch (\Exception $e) {
    echo 'Something went wrong: '.$e->getMessage()."\n";
    exit(0);
}

try {
    $ig->uploadTimelinePhoto($photoFilename, ['caption' => $captionText]);
} catch (\Exception $e) {
    echo 'Something went wrong: '.$e->getMessage()."\n";
}

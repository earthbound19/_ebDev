: DESCRIPTION
:Scans an 8.5 x 11 inch 100 dpi grayscale PNG image via wia-cmd-scanner, a CLI windows fax and scan-accessing utility. PNG file is named SCAN_<date_and_time>.png.

: USAGE
: Copy the script to a directory you want scanned images to be placed in, and double-click it.

: CODE
: Date formatting ganked from: https://stackoverflow.com/a/1445724
: Sets date and time stamp with 24Hr time down to the second

@ECHO OFF
SET dtStamp=%date:~-4%_%date:~4,2%_%date:~7,2%__%time:~0,2%_%time:~3,2%_%time:~6,2%

wia-cmd-scanner /w 215.9 /h 279.4 /dpi 100 /color GRAY /format PNG /output ".\SCAN_%dtStamp%.png"
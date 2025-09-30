: DESCRIPTION
:Scans an 8.5 x 11 inch 100 dpi grayscale PNG image via wia-cmd-scanner, a CLI windows fax and scan-accessing utility. PNG file is named SCAN_<date_and_time>.png.

: USAGE
: Copy the script to a directory you want scanned images to be placed in, adjust the scan flags in the wia-cmd-scanner command as you may want to, and double-click this batch file or invoke it from a command line.

: CODE
: Date formatting ganked from: https://stackoverflow.com/a/1445724
: Sets date and time stamp with 24Hr time down to the second

@ECHO OFF
set datestamp=%date%__%time:~0,2%_%time:~3,2%_%time:~6,2%

wia-cmd-scanner /w 215.9 /h 279.4 /dpi 100 /color GRAY /format PNG /output ".\SCAN_%datestamp%.png"
; OR e.g. for a 300 dpi color scan:
; wia-cmd-scanner /w 215.9 /h 279.4 /dpi 300 /color RGB /format PNG /output ".\SCAN_%datestamp%.png"

: OR to modify this to scan a color image at 600 dpi:
: wia-cmd-scanner /w 213.87 /h 294.89 /dpi 600 /color RGB /format PNG /output ".\SCAN_%datestamp%.png"

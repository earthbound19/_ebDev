REM DESCRIPTION
REM RUNS TRONSCRIPT windows debloat / disinfect / maintenance super-script, with preferred switches.

REM USAGE
REM Copy this script to the same folder as the extracted tron.bat. Run this script from a cmd prompt (maybe as an Administrator).

REM DEPENDENCIES
REM tronscript (you'll find it with an internet search)

tron.bat -a -e -p -sa -sd -v

REM REFERENCE: these switches skip windows updates and custom user windows updates:
REM -swu -swo
REM REBOOT AUTOMATICALLY:
REM -r 
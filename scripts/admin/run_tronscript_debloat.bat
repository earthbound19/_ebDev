:: DESCRIPTION
:: Runs the tronscript for Windows debloat / disinfect / maintenance super-script, with preferred switches.

:: DEPENDENCIES
:: tronscript (you'll find it with an internet search)

:: USAGE
:: Copy this script to the same folder as the extracted tron.bat. Run from a cmd prompt (maybe as an Administrator):
::    run_tronscript_debloat.bat


:: CODE
:: REFERENCE: these switches skip windows updates and custom user windows updates:
:: -swu -swo
:: REBOOT AUTOMATICALLY:
:: -r 
tron.bat -a -e -p -sa -sd -v

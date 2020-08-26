:: DESCRIPTION
:: I don't know what this does. I also don't care anymore. This script is vestigial. MSoft toasted gadgets at some point; this script or "batch file" can only apply to older versions of Windows.

:: USAGE
:: Run without any parameter:
::    ResetWin7Gadgets.bat
:: ATTRIBUTION
:: Created by: Shawn Brink
:: http://www.sevenforums.com
:: Tutorial:  http://www.sevenforums.com/tutorials/140358-gadgets-not-displaying-correctly-windows-7-fix.html


:: CODE
taskkill /im sidebar.exe /f
regsvr32 /s msxml3.dll 
regsvr32 /s scrrun.dll
regsvr32 /s jscript.dll
regsvr32 /s atl.dll
Regsvr32 /s "%ProgramFiles%\Windows Sidebar\sbdrop.dll" 
Regsvr32 /s "%ProgramFiles%\Windows Sidebar\wlsrvc.dll"
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones" /f 
"%ProgramFiles%\Windows Sidebar\sidebar.exe" 

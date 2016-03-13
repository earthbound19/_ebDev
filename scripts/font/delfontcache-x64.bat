REM if it's even necessary to delete these files which I suppose are font caches, maybe the need can be eliminated by disabling the Windows Font Cache Service (under Services).
REM DEL C:\Windows\Fonts\texgyrecursor*
REM COPY C:\FontForge-working\texgyrecursor* C:\Windows\Fonts\
DEL C:\Windows\System32\FNTCACHE.DAT
DEL C:\Users\%USERNAME%\AppData\Local\GDIPFONTCACHE*
DEL "%USERPROFILE%\Local Settings\Application Data\GDIPFONTCACHEV*"
DEL C:\Windows\Fonts\*.dat
DEL C:\Windows\Fonts\*.xml
DEL "C:\Program Files (x86)\FontForge\.FontForge\autosave\auto*"
REM RE http://cjwdev.wordpress.com/2011/06/12/install-fonts-for-logged-on-user-via-sccm-package/:
REM EXCEPT THAT ALL THROWS AN ERROR, SO . . .
REM SET CURRENTDIR=%CD%
REM CD C:\devbin\_devbin\ReloadChangedFontInCurrentSessionHackTools\
REM ECHO current dir is %CURRENTDIR%
REM DEL C:\Windows\Fonts\desktop.ini
REM StartInConsoleSession.exe C:\CurrentSessionFonts.exe add C:\Windows\Fonts\texgyrecursor-regular.otf
REM StartInConsoleSession.exe C:\CurrentSessionFonts.exe add C:\Windows\Fonts\texgyrecursor-italic.otf
REM CD %CURRENTDIR%
FontReg.exe
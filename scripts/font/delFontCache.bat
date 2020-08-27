:: DESCRIPTION
:: Wipes the Windows font cache for x32 systems, which can be silly stubborn and render from outdated font files even after you update and reinstall fonts in development, and which font cache service you should have disabled for that reason anyway.

:: DEPENDENCIES
:: FontReg.exe, from . . . ? I collected this executable from somewhere? It updates Windows font registration or cache or some other magic.

:: USAGE
:: Run via command prompt or double-click:
::    delFontCache.bat


:: CODE
DEL C:\Windows\System32\FNTCACHE.DAT
DEL C:\Users\%USERNAME%\AppData\Local\GDIPFONTCACHE*
DEL C:\Users\%USERNAME%\AppData\Local\GDIPFONTCACHEV*
DEL C:\Windows\Fonts\*.dat
DEL C:\Windows\Fonts\*.xml
DEL "C:\Program Files (x86)\FontForge\.FontForge\autosave\auto*"
FontReg.exe
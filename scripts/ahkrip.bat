:: DESCRIPTION
:: Compiles executable %1 (parameter 1), which should be an .ahk (AutoHotkey) script, to an executable, via Ahk2exe.

:: DEPENDENCIES
:: Ahk2exe installed somewhere and in your PATH.

:: WARNING
:: This will erase and recreate any ahk-generated .exe files in the directory in which it is run!

:: USAGE
:: Run with one parameter, which is the file name of an AutoHotkey script ready to compile to an .exe, for example:
::    ahkrip.bat tweak_mouse_keepalive.ahk
:: Resultant executables will have the same base file name as the script compiled.


:: CODE
SET CURRDIR=%CD%
SET CURRDRIVE=%cd:~0,2%

%CURRDRIVE%
Ahk2exe.exe /in %CURRDIR%\%1.ahk /out %CURRDIR%\%1.exe /icon %CURRDIR%\iconConverter\ffBatch-run.ico
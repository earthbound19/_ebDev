REM What is this supposed to do versus actually do? I don't think I want to "obliquify" (ITALICIZE?) anything. 06/26/2014 05:33:35 PM -RAH

REM I think I can modify the .pe script it calls to do a veriety of things? 08/13/2014 06:07:04 PM -RAH

@echo ON
set FF=%~dp0
set PATH=%FF%\bin;%FF%\bin\Xming-6.9.0.31;%PATH%
set DISPLAY=:9.0
set XLOCALEDIR=%FF%\bin\Xming-6.9.0.31\locale
set AUTOTRACE=potrace
set HOME=%FF%

start /B "" "%FF%\bin\Xming-6.9.0.31\Xming.exe" :9 -multiwindow -clipboard -silent-dup-error -notrayicon

"%FF%\bin\Xming_close.exe" -wait

REM "%FF%\bin\fontforge.exe" -script obliquify.pe
"%FF%\bin\fontforge.exe" -script convert.pe

"%FF%\bin\Xming_close.exe" -close

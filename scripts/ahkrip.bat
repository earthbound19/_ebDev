REM ECHO WARNING: This script will erase and recreate any ahk-generated .exe files in this directory! Also note that this script expects the given Ahk2exe.exe compiler to be in your %PATH%.

SET CURRDIR=%CD%
SET CURRDRIVE=%cd:~0,2%

%CURRDRIVE%
Ahk2exe.exe /in %CURRDIR%\%1.ahk /out %CURRDIR%\%1.exe /icon %CURRDIR%\iconConverter\ffBatch-run.ico
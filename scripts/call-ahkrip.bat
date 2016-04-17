REM DESCRIPTION: rips all .ahk files in the directory from which this script is called--rips them to .exe files using ahkrip.bat (which) in turn uses ahk2exe.exe).

REM USAGE: Execute this batch. ahkrip.bat must be in the same directory as this.

REM TO DO? : consolidate ahkrip.bat into this.

ECHO OFF

REM COPY _temp\*.txt ..\
REM (Those had been some text files used in development.)

SET CURRDIR=%CD%
SET CURRDRIVE=%cd:~0,2%

REM REBUILD TARGETS
ECHO OFF
FOR %%A IN (%CURRDIR%\*.ahk) DO (
ahkrip.bat %%~nA
%CURRDRIVE%
CD %CURRDIR%
REM MOVE /Y %CURRDIR%\%%~nA.exe ..\
)
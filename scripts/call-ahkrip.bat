:: DESCRIPTION
:: Runs ahkrip.bat (SEE) for all .ahk files in the directory from which this script is called.

:: DEPENDENCIES
:: You must have ahkrip.bat in the same directory as this (or possibly just in your PATH).

:: USAGE
:: From a directory with one or more .ahk (AutoHotkey) scripts ready to be compiled to executables, run this script:
::    call-ahkrip.bat
:: See USAGE in ahkrip.bat for expected results.


:: CODE
ECHO OFF
:: COPY _temp\*.txt ..\
:: (Those had been some text files used in development.)

SET CURRDIR=%CD%
SET CURRDRIVE=%cd:~0,2%

:: REBUILD TARGETS
ECHO OFF
FOR %%A IN (%CURRDIR%\*.ahk) DO (
ahkrip.bat %%~nA
%CURRDRIVE%
CD %CURRDIR%
:: MOVE /Y %CURRDIR%\%%~nA.exe ..\
)
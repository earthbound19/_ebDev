REM Drop a lot of .txt files on this batch to combine them into one .txt file archive.

SETLOCAL ENABLEDELAYEDEXPANSION

FOR %%Y IN (%*.txt) DO (
======================================
REM ECHO %%Y
TYPE %%Y >> __compilation.txt
)
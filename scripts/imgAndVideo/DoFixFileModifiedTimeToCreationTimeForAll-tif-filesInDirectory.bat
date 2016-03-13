SETLOCAL ENABLEDELAYEDEXPANSION

DIR /B *.tif > tifFileList.txt
FOR /F "delims=*" %%F IN (tifFileList.txt) DO (
FixFileModifiedTimeToCreationTime.ahk "%%F"
)
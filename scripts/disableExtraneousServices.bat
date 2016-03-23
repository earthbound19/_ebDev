FOR /F "delims=*" %%A IN (%CD%\extraneousServices.txt) DO (
SC STOP "%%A"
SC CONFIG "%%A" START= DISABLED
)

process -k GWX.exe
MKDIR %CD%\tempEmptyDir
ROBOCOPY tempEmptyDir "C:\Windows\System32\GWX" /E /PURGE
RMDIR tempEmptyDir
RMDIR "C:\Windows\System32\GWX"
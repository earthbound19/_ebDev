:: DESCRIPTION
:: Tests the performance of a disk associated with a Windows install.

:: USAGE
:: RUN WITH one parameter, which is the drive letter (no : or \ in it) you want to test, for example:
::    winsat_drive_test.bat C


:: CODE
:: Re: https://superuser.com/questions/130143/how-to-measure-disk-performance-under-windows
winsat disk -drive %1
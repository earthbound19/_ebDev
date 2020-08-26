:: DESCRIPTION
:: Super toasts the security problem which RDP is, by deleting ALL files on the system drive which have "Mstsc" in the file name, AND deleting associated services.

:: USAGE
:: From a command prompt with administrator privileges, run this script:
::    toastWindowsRDP.bat


:: CODE
:: TO DO? : make Mstcs a parameter (NUKE EVERYTHING OF A PARAMETER NAME), set script to only execute after warning and affirm from user, rename script.

SC STOP SessionEnv
SC DELETE SessionEnv
SC STOP TermService
SC DELETE TermService
SC STOP UmRdpService
SC DELETE UmRdpService


:: DEPRECATED: just find mstsc.exe in syswow 32 and 64 folders and rename it instead:
:: PUSHD %CD%
:: CD /
:: MKDIR nukeSubDir
:: DIR * /AD /B /S | FINDSTR /E /I \Mstsc > nukeList.txt
:: SET /A NUM = %NUMBER_OF_PROCESSORS% * 3
:: FOR /F "delims=*" %%A IN (nukeList.txt) DO (
:: ROBOCOPY nukeSubDir "%%A" /E /PURGE /MT:%NUM% /W:0 /R:0
:: )
:: DEL nukeList.txt
:: RMDIR nukeSubDir
:: POPD
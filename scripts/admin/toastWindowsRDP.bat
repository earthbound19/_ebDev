REM DESCRIPTION
REM Super toasts the security problem which RDP by deleting ALL files on the C drive which have "Mstsc" in the file name, AND deleting associated services.

SC STOP SessionEnv
SC DELETE SessionEnv
SC STOP TermService
SC DELETE TermService
SC STOP UmRdpService
SC DELETE UmRdpService

REM TO DO? : make Mstcs a parameter (NUKE EVERYTHING OF A PARAMETER NAME), set script to only execute after warning and affirm from user, rename script.

REM DEPRECATED: just find mstsc.exe in syswow 32 and 64 folders and rename it instead:
REM PUSHD %CD%
REM CD /
REM MKDIR nukeSubDir
REM DIR * /AD /B /S | FINDSTR /E /I \Mstsc > nukeList.txt
REM SET /A NUM = %NUMBER_OF_PROCESSORS% * 3
REM FOR /F "delims=*" %%A IN (nukeList.txt) DO (
REM ROBOCOPY nukeSubDir "%%A" /E /PURGE /MT:%NUM% /W:0 /R:0
REM )
REM DEL nukeList.txt
REM RMDIR nukeSubDir
REM POPD
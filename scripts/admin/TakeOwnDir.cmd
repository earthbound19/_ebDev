:: DESCRIPTION
:: Takes ownership of a directory %1 (parameter 1). See also InstallTakeOwnership.reg.

:: USAGE
:: From a cmd prompt, possibly with Administrator privileges, run with one parameter, which is the name of a folder to take ownership of:
::    TakeOwnDir.cmd stubbornlyInaccessibleFolder


:: CODE
"%ProgramFiles%\Windows Resource Kits\Tools\subinacl.exe" /subdirec %1 /owner=Administrators /grant=Administrators=F
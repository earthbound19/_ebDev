:: DESCRIPTION
:: Takes ownership of a file %1 (parameter 1). See also InstallTakeOwnership.reg.

:: USAGE
:: From a cmd prompt, possibly with Administrator privileges, run with one parameter, which is the name of a file to take ownership of:
::    TakeOwnFile.cmd stubbornlyInaccessibleFile.txt


:: CODE
"%ProgramFiles%\Windows Resource Kits\Tools\subinacl.exe" /file %1 /owner=Administrators /grant=Administrators=F
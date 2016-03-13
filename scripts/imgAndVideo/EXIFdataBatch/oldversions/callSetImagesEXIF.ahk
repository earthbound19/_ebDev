#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Loop, %1%\*.*, 0, 1
	{
	fileNamesArray.Insert(A_LoopFileFullPath)
	}
	
for index, element_fileNamesArray in fileNamesArray
{
MsgBox, file name is %element_fileNamesArray%
}
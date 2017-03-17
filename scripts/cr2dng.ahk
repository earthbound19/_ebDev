#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]

fileExistsCount = 0

; Loop, *.CR2
	; {
    ; name = %A_LoopFileName%
    name = %1%
	SplitPath, name,,,, nameNoExt
	;MsgBox, val is: %nameNoExt%
	IfNotExist, %nameNoExt%.dng
		{
; TO DO: change that path to %programfiles%\~ or summat:
		RunWait, AdobeDNGConverter.exe -c -p1 -fl %name%,, Max
		}
		else
		{
		fileExistsCount += 1
		}
	; }

; If (fileExistsCount > 0)
	; {
	; MsgBox, Number of .CR2 images for which matching .dng file names existed (so conversion was skipped) is: :`n`n%fileExistsCount% 
	; }
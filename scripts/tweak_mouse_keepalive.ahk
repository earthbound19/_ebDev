#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent
#SingleInstance force
#NoTrayIcon
; OnExit, ExitSub
; MsgBox %A_ScriptName%

loop
{
MouseMove, 2, 0, 0, R
Sleep, 600
MouseMove, -2, 0, 0, R
Sleep, 4500
}

; Doesn't work for a compiled .exe:
; ExitSub:
; {
; FileDelete, %A_ScriptName%
; ExitApp		; A script with an OnExit subroutine will not terminate unless the subroutine uses ExitApp.
; }
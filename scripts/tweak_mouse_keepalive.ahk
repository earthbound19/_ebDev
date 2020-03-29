#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent
#SingleInstance force
; #NoTrayIcon

MsgBox Sending one pixel left/right mouse movement every 50 seconds so the computer will not go to screensaver, sleep, or hibernate.

loop
{
MouseMove, 1, 0, 0, R
Sleep, 50000
MouseMove, -1, 0, 0, R
Sleep, 50000
}
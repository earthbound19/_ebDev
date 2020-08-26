
; DESCRIPTION
; Moves the mouse by one pixel every 50 seconds, so that idle timeout events (such as screensaver activation or the screen going blank) don't happen. Useful for keeping all system computing resources possible available for renders without any other system events causing resource drain, or for things like watching internet movies without the screensaver interrupting.

; DEPENDENCIES
; AutoHotkey installed and associated with .ahk scripts.

; USAGE
; Double-click this file:
;    tweak_mouse_keepalive.ahk
; OR compile it to an executable via `ahkrip.bat` / `Ahk2exe.exe`. 


; CODE
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
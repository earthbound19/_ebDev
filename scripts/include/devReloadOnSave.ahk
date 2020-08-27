; DESCRIPTION
; Allows for any AutoHotkey scripts that `#Include` this script to be dynamically reloaded as executable programs running on the system, for testing-in-development purposes, via keypress of `CTRL + ALT + /` (forward slash).
; Adapted from BETLOG's modification, re:http://www.autohotkey.com/board/topic/122-automatic-reload-of-changed-script/page-2

; USAGE
; To cause any script to function as explained under DESCRIPTION, copy this script into the same directory as the script you are developing, and then in your development script, copy the lines of code from this script between the labels " ---- BEGIN AUTO-RELOAD INCLUDE" and " ---- END AUTO-RELOAD INCLUDE," but removing the comments (semicolons) from the start of the code lines in that include section. You may also be able to include this script by _not_ copying it into the same directory of your development script, and only adjusting the include code line to an absolute or relative path to this script. See also the NOTE right after that comment section.

; CODE
; ---- BEGIN AUTO-RELOAD INCLUDE
; GoSub START
; #Include devReloadOnSave.ahk
; START:
; ---- END AUTO-RELOAD INCLUDE
; NOTE
; You may also use code like the following if you wish for a stop before a reloaded script executes. Just be aware that if you have other includes, this execution change may interfere with their proper loading; re: http://ahkscript.org/docs/commands/MsgBox.htm
; MsgBox, 4, , Test script?
; IfMsgBox No
;    ExitApp
;	Return


SPLASH:
{
SplashImage,, b1 cw008000 ctffff00, Reloading %A_ScriptName%.
Sleep, 1200
SplashImage, Off
return
}

~^!/::	;HOTKEY_COMMENT [For programmers] CTRL+ALT+/ (forward slash, on the ? question mark key) reload all AutoHotkey scripts that include this hotkey, and restart their execution
SetTitleMatchMode, 2
IfWinActive,%A_ScriptName%		; ---- Make a small splash screen notice appear in
	{							; any (and every?) window which includes this file.
	GoSub, SPLASH
	Reload
; TO DO; Determine: is the following line necessary? Does it result in twice reloading the script?
	GoSub, START
	}
return
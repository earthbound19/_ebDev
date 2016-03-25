; DESCRIPTION: devReloadOnSave.ahk: reload all scripts which include this, via keypress: CTRL+ALT+/ (forward slash, on the ? question mark key).

; Adapted from BETLOG's modification, re:http://www.autohotkey.com/board/topic/122-automatic-reload-of-changed-script/page-2
; To cause any script to function as described in the below comment block labeled "AUTO-RELOAD ON SAVE," copy that comment block into the script of your choosing, and then uncomment the code lines of the block:

; ---- AUTO-RELOAD INCLUDE
; ---- Reload this script and restart execution whenever CTRL+ALT+? (/) is typed:
; GoSub START
; #Include devReloadOnSave.ahk
; START:
; ---- END AUTO-RELOAD INCLUDE


/* NOTE
You may use code like the following if you wish for a stop before a reloaded script executes. Just be aware that if you have other includes, this execution change may interfere with thier proper loading:
; re: http://ahkscript.org/docs/commands/MsgBox.htm
;/*
MsgBox, 4, , Test script?
IfMsgBox No
    ExitApp
	Return
*/


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
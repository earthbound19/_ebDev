#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]

fileExistsCount = 0

MsgBox WARNING! If you click "Ok," all image/media metadata in all image (or any other file types) in this directory will be irrevocably WIPED OUT! Even if you click the X close button, this will happen! If you do not want this, right-click the systray icon for this script and click "exit."

Loop, *.*
	{
    name = %A_LoopFileName%
		{
		RunWait, exiftool -overwrite_original -imageorientation="Rotate 270 CW" %name%,, Hide
		}
	}
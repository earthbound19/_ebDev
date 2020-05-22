; TO DO: Move this out of the _devtools/bin path to a proper permanent tools path.
; TO DO: See if the text files given in USAGE below are even used (or could be).

; DESCRIPTION:
; Creates a batch file, _rename_images.txt (rename it to a .bat file to use it), which renames all files in a directory tree such that windows and 'nix envrionments will handle the files without errors from special characters, etc. Optionally and in development: it will shorten the files to a specified length. It also outputs two lists; one of the original file names (imgs_original_names.txt) and another of the proposed modified file names (imgs_new_names.txt). To keep a record of renames, or for other purposes.

; USAGE: To be written . . . 

; NOTES: 1) This script will not work as expected called from a cygwin shell if you call the .ahk version of this. However, if you compile this script to a .exe, it will work from cygwin. 2) File names passed to this which include spaces (' ') must be surrouned by double-quote marks.


; TO DO: update the following doc. per conditional param. %3%.
; USAGE: This script expects three parameters. The first two should be surrounded by double quote marks ", the first being a path to work in, the second being a file in that path to work upon, and the third being a length to shorten the file name to. If the given file is shorter than or equal to the length to shorten to, it will not shorten the file name. All three parameters must be given, and in that order. NOTES: The text files it creates are imgs_original_names.txt and imgs_proposed_new_names.txt; *it only ever appends* to these text files. This means they add to the text files, but never blank or delete them. Consequently, anytime you wish to recreate those lists with a series of runs of this program, you must first blank or delete those files. LASTLY, if you have spaces in any of the directories in the path to the image files this script uses, it will probably break functionality. Ensure there are only e.g. underscores _ in the PATH, no spaces.

; LICENSE: I wrote this and release it to the Public Domain. 10/13/2015 07:03:02 AM -Richard Alexander Hall

; TO DO: Get this properly renaming some files it won't rename (with special characters); AND/OR warn user of impossible to handle characters in file names (list them if possible); as the varize() function may not process those characters (and the characters would cause errors if in variables).

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#NoTrayIcon
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; ======================================
; ======== GLOBAL FUNCTIONS ========
; NOTE: This function is for a future version of this script which will truncate file names to a specified length. At this writing, this function is not used.
; Adapted from (and thanks for help at) http://www.autohotkey.com/board/topic/16860-how-to-generate-a-random-string-chars-like-fghdhfghdf/ :
getRandomChar() {
Array := Array("A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "m", "n", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "2", "3", "4", "5", "6", "7", "8", "9")
Random, selectedChar, 1, 56
randomChar := Array[selectedChar]
return randomChar
}

; Varize function copied from ffBatch.ahk, and there from another source altogether.
varize(var)
{
	; Re: http://stackoverflow.com/a/1488550/1397555
	; TO DO: regexreplace to delete stubbornly stupid early stuck periods. Here's a start: https://regex101.com/r/rD0lD1/1 -- 10/13/2015 09:34:45 PM -RAH
		; Reference: NewStr := RegExReplace(Haystack, NeedleRegEx [, Replacement = "", OutputVarCount = "", Limit = -1, StartingPosition = 1])
		; var := RegExReplace(var, NeedleRegEx [, Replacement = "", OutputVarCount = "", Limit = -1, StartingPosition = 1])
	; Removes periods in the middle of file names while leaving the extension (up to a dot and four letters) intact:
	var := RegexReplace( var, "(\.+)([^.]{5,})", "$2" )
	; Replaces all spaces with underscores:
	stringreplace,var,var,%A_space%,_,a
	; !===== NOTE: of the two following options, only use one (and comment out the other). =====!
		; MORE RIGOROUS option:
	chars = ,<>:'/|\=+!`%^&*~#@$[](){}``;
		; LESS RIGOROUS option:
	; chars = ,<>:'/|\=+!`%^&*~#@$``;
	; NOTE: ommited from that: . \/ "
	loop, parse, chars,
	stringreplace,var,var,%A_loopfield%,,a
	return var
}
; ======== END GLOBAL FUNCTIONS ========
; ======================================


workPath=%1%
fullFileName=%2%
; MsgBox workPath val is`n%workPath%,`nfullFileName val is`n`n%fullFileName%.

; NOTE: The following code block affects nothing at this writing. See comment for getRandomChar() function above.
	emptyComparisonString=
	num = %3%
	; If paramater 3 (the length to shorten a file name to) was not passed, set the variable num to a flag that says do not rename. If 3 was used, set num to the value of 3 (which should be a number, and if it isn't, it will break this script).
	If (num == %emptyComparisonString%)
		{
			num=DONOTSHORTEN
			; MsgBox, Will *not* shorten file names.
		}
			Else
		{
			num=%num%		; Because autohotkey can do weird things with strings otherwise
	num-=5					; Because we're going to add four random alphanumeric characters and a tilde ~ to the name (to avoid any duplicate file names).
			; MsgBox, Will shorten file names.
		}

val := varize(fullFileName)
StringReplace, val, val, Zenfolio_Image_-_, Zenfolio_IMG-, All
StringReplace, val, val, Bing_Image_Search_Image_-_, Bing_IMG-, All
StringReplace, val, val, Google_Image_Search_Image, Goog_IMG-, All
StringReplace, val, val, Flickr_Image_-, flikr-, All
StringReplace, val, val, flikr--, flikr-, All
; No, seriously, it can miss gratuitious repetitions of special characters unless I perform each of the following replacements *twice*. 10/13/2015 09:26:39 PM -RAH
StringReplace, val, val, _-_, -, All
StringReplace, val, val, _-_, -, All
 StringReplace, val, val, --_, --, All
 StringReplace, val, val, --_, --, All
StringReplace, val, val, _--, --, All
StringReplace, val, val, _--, --, All
 StringReplace, val, val, ...., --, All
 StringReplace, val, val, ..., --, All
StringReplace, val, val, .., --, All
StringReplace, val, val, .., --, All
  StringReplace, val, val, ---, --, All
  StringReplace, val, val, ---, --, All
StringReplace, val, val, ---, --, All
StringReplace, val, val, ---, --, All
 StringReplace, val, val, ___, __, All
 StringReplace, val, val, ___, __, All
StringReplace, val, val, _._, __, All
StringReplace, val, val, _._, __, All
; re: https://autohotkey.com/docs/commands/SplitPath.htm :
; Reference: SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
SplitPath, val,,, OutExtension, OutNameNoExt
		; MsgBox, ext`n%OutExtension%`nOutNameNoExt`n%OutNameNoExt%

; Because ahk can crash if it evaluates a file name with an unfriendly character in it, we can't check here for equality of the new and old filename; we simply write the new and old both to a batch file. Whether they're identical can be filtered out of the batch by other tools before proposing the batch be run. It is, however, honky-dory if I print the original file name to a file. Again, it's string equality checking that can crash.
newFileName = %OutNameNoExt%.%OutExtension%
; %fullFileName% is the original file name:
FileAppend, %fullFileName%`n, %workPath%\imgs_original_names.txt
FileAppend, %newFileName%`n, %workPath%\imgs_new_names.txt
		; DEPRECATED: I think including the full path was screwing it up--DOS can't handle a command that's too long.
		; FileAppend, REN "%workPath%\%fullFileName%" "%workPath%\%newFileName%"`n, %workPath%\_rename_images.txt
; MsgBox, newFileName val is`n`n%newFileName%.
		; Direct autohotkey file manipulation option, in development (may never be finished) :
		; FileMove, %fullFileName%, %newFileName%
		; Then use errorlevel here to determine any rename failures.
; Batch option:
FileAppend, REN "%fullFileName%" "%newFileName%"`n, %workPath%\_rename_images.txt

; ===== REVISION HISTORY =====
; 01/05/2016 12:35:29 AM a lot of work on this prior. Debugged with its companion fixIMGnames.sh into workable shape. -RAH
; 01/31/2016 06:40:22 PM Updated and clarified comments, tested.
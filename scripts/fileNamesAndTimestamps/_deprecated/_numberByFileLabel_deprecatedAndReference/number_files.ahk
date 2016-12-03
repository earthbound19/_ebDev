#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; NOTE: For this program to work as intended, you must follow the rules of naming files after this convention:
;Offset the files you want counted with dashes or underscores (- or _). Do not precede the first underscore with any of the letters L, l, i, b, r, a, y, x, or X, or the dot character (.).
; TO DO: Note other conditions and how this functions here.
; TO DO: Abstract this further to do things conditioned on a label passed to it (%2%) -- instead of the hard-coded regex [-_]{1}final[-_]{1}

; MsgBox, Search path:`n%1%`n`nLabel to apply to matched file names:`n%2%

fileNamesArray := Object()
baseIndexSearchArray := Object()
; Re: http://www.autohotkey.com/board/topic/13606-ahkarray-real-array-one-variable-version-6/
searchExtensions := ["psd", "tif", "tiff", "png", "kra", "jpg", "jpeg", "bmp", "rif", "svg"]

Loop, %1%\*.*, 0, 1
	{
	fileNamesArray.Insert(A_LoopFileFullPath)
			; FOR TESTING ONLY; comment out in production:
			; StringTrimLeft, tempString, A_LoopFileFullPath, 46
			; Command used to create test directory full of duplicate although zero-length files: ROBOCOPY "\\dumbledore\d$\Alex\Art\_Abstractions series" C:\Users\Tia\Desktop\Alex\_artDev\testDir /E /MT:8 /CREATE
			; FileDelete, %A_ScriptDir%\testDir\%tempString%
			; FileAppend, Hello world!, %A_ScriptDir%\testDir\%tempString%
	}

FileDelete, fileNumLog.txt
FileAppend,, fileNumLog.txt
Sleep, 645
RegExNeedle = [^LlibrayxX\.][-_]{1}([0-9]{5})[-_]{1}	; Any group of five consecutive digits not preceded or followed by the characters . - x and X (which are used for electric sheep and filenames that list dimensions as NxN, and files named from Filter Forge libraries, *and* filenames that have more than 5 consecutive numbers, all of which otherwise would produce false positive matches).
for index, element in fileNamesArray
{
			; Reference: SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
	SplitPath, element, , , fileExtension
	extensionListMatchBool = 0
	for index2, element2 in searchExtensions
		{
		if (fileExtension == element2) {
			extensionListMatchBool = 1
			}
		}
	if (extensionListMatchBool == 1) {
		SplitPath, element, fileName
		matchFoundBool := RegExMatch(fileName, RegExNeedle, needleRegExMatch)
		if (matchFoundBool != 0) {
			baseIndexSearchArray.Insert(needleRegExMatch)
			FileAppend, %fileName%`n, fileNumLog.txt
			}
		}
}

; Identify the highest number among numbered files, and store it in the variable baseIndex.
baseIndex = 0
for index, element in baseIndexSearchArray
	{
	StringTrimLeft, element, element, 2
	StringTrimRight, element, element, 1
	if (baseIndex < element) {
		baseIndex = %element%
		}
	}

; UNCOMMENT this next line for production!
MsgBox, If you need to rename any files (as will be explained), right-click the system tray icon for this program, then click exit. Then rename the files, and run this program again. I have listed all files that match the regex needle:`n`n%RegExNeedle%`n`nin:`n`n%A_ScriptDir%\fileNumLog.txt`n`nExamine that file for any false positives (files that have a number that is not an index but looks like one), and rename them such that they will not produce a false positive. The rules are:`n`nOffset the files you want counted with dashes or underscores (- or _), and number the files with five consecutive digits. Do not precede the first underscore with any of the letters L, l, i, b, r, a, y, x, or X, or the dot character (.), e.g.:`n`n abstraction_00375_`n`nThe highest indexed file number I found was %baseIndex%.`n`nIf you are okay to proceed after these checks, click "Ok" to continue.

; === CHECK all file names/containing folder names in fileNamesArray, and do things with them:
fileParentDir=
lastSeenParentDir=
searchFolderHasChangedBool = 0
folderHasNumberBool = 1
folderHasFinalBool = 0
for index, element in fileNamesArray
{
		; Reference: SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
SplitPath, element, fileNameInSearchPath
		; Deprecated approach to store the name of the folder containing the file (element) in the variable trimmedFileDir; it would function properly if autoHotkey supported non-capture groups, re https://regex101.com/r/vT3tD4/2 : RegExNeedle = (?:.*\\)(.*)(?:[\\])
			; MsgBox, Examining:`n`n%element% . . .
; === ISOLATE parent folder name of the folder containing the current listed file. The following creates a new array directoriesAboveFileArray:
StringSplit, directoriesAboveFileArray, element, \
Loop, %directoriesAboveFileArray0%
	{
	this_check := directoriesAboveFileArray%a_index%
	usedIndex = %a_index%
	}
usedIndex -= 1
fileParentDir := directoriesAboveFileArray%usedIndex%
; === CHECK if parent folder of this filename differs from the previous seen parent folder name; and if so, set a bool which will be used in conjunction with other bools (relating to all files in the previous seen folder) to determine whether to rename the previous seen folder and all files in it, according to criteria . . .
; === CHECK whether to set boolean searchFolderHasChangedBool, and if it should be set (to true), do so.
; TO DO: detail those criteria here.
if (lastSeenParentDir == "") {
	lastSeenParentDir = %fileParentDir%
	searchFolderHasChangedBool = 0
	}
	else {
	if (fileParentDir != lastSeenParentDir) {
			; MsgBox, fileParentDir value is:`n`n%fileParentDir%`n`n--and lastSeenParentDir value is:`n`n%lastSeenParentDir%
		searchFolderHasChangedBool = 1
		;lastSeenParentDir = %fileParentDir%
		} else {
		searchFolderHasChangedBool = 0
		}
	}
; ====== FOLDER NAME CHECK: NUMBER
; === CHECK if folder is numbered and store not/is state in folderHasNumberBool.
; NOTE: create an important check var:
RegExNeedle = ([0-9]{5})
folderHasNumberBool := RegExMatch(fileParentDir, RegExNeedle, needleRegExMatch)
					if (folderHasNumberBool != 0) {
					 ;MsgBox, value of folderHasNumberBool is %folderHasNumberBool% for folder %fileParentDir% for RegExNeedle %RegExNeedle%
					; . . .
					; Or do nothing.
					}
; ====== FOLDER NAME CHECK: INCLUDES PHRASE "final"
; === CHECK if folder includes the word final and store not/is state in folderHasFinalBool.
; NOTE: CHANGING the RegExNeedle defined earlier, AND create an important check var:
RegExNeedle = (?im)(_final_)
; TO DO? Make that match more demanding: ([-_][final][-_])
; --and not case-sensitive.
folderHasFinalBool := RegExMatch(fileParentDir, RegExNeedle, needleRegExMatch)
		if (folderHasFinalBool != 0) {
				;MsgBox, value of folderHasFinalBool is %folderHasFinalBool% for folder %fileParentDir% for RegExNeedle %RegExNeedle%
		; . . .
		; Or do nothing.
		}
; === NOT COMPLETE--IN DEVELOPMENT:
if (folderHasNumberBool == 0 && folderHasFinalBool == 1) {
		MsgBox, File as rename candidate:`n`n%element%
	; RESET booleans, else this block will not function as intended.
	}
}

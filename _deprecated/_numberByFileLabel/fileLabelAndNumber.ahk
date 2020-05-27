#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

;Reference: MsgBox [, Options, Title, Text, Timeout]
MsgString = WARNING: Back up your files first! This program has no guarantees or warranty and could mess things up.`n`nNOTE: If you have a lot of files you *don't* want tagged with new numbers, and which are similarly named (e.g. "variant 01," "var. 02," "variation 05," etc.), this program may mess up in numbering. You can control for that by file naming. If you name every alternate/variation file "variant;" this program will deliberately ignore (not renumber) all those files.`n`nNOTE: Although this program sorts tagged files into new folders by number, if you have any files tagged _final already within a numbered folder, it will ignore the folder numbering, and number the tagged file regardless (which could result in files with a higher number in a lower-numbered folder). To avoid that happening where not intended, make sure that all _final files in any numbered folder are properly, similarly numbered!
MsgBox, 1, Back up your work and rename duplicates first!, %MsgString%
	IfMsgBox, Cancel
		{
		MsgBox, 0, Terminating execution . . ., Will not attempt any file scan or renames. Terminating program., 3
		Exit
		}
	IfMsgBox, OK
		{
		;Nothing, proceed as normal . . .
		}

; FOR TESTING ONLY; COMMENT OUT THE FOLLOWING FOUR LINES FOR PRODUCTION:
; #Persistent
; GoSub START
; #Include devReloadOnSave.ahk
; START:

		;FOR DEVELOPMENT ONLY--COMMENT OUT IN PRODUCTION:
		  ; 1 = C:\Users\Tia\Desktop\Alex\_artDev\testDir
		  ; 2 = _abstraction_

; === TASKS
; Task list key: * = done, ! = in progress.

; TO DO? Add file rename revert option (using created log)?
; TO DO? : Abstract this further to do things conditioned on a label passed to it (%2%) -- instead of the hard-coded regex.
; * TO DO: Fix highest number counting (is broken)
; * TO DO: Bug fixes for; won't match num that is start of name, OR require number to be in middle of file name. (Fixed by using better regular expression.)
; TO DO: PROCESS FOLDERS TOO (for numbering, also do renaming) . . .
; === END TASKS

; === GLOBALS
searchExtensions := ["psd", "tif", "tiff", "png", "kra", "ptg", "jpg", "jpeg", "bmp", "rif", "svg", "PSD", "TIF", "TIFF", "PNG", "KRA", "PTG","JPG", "JPEG", "BMP", "RIF", "SVG"]		; Tried case-insensitive string comparison mode--it didn't work! (Case-insensitive comparison would make it unnecessary to include all caps extension variants in that list, and if there's a bizarre case of mixed capitals in an extension, it won't match.)
fileNamesArray := Object()
tempArray := Object()
baseIndexSearchArray := Object()
baseIndex = 0	; This will store the highest found numbered file (which we want to count up to number files with this script).
candidateNumberingFiles := Object()
filesOrPathsToRenumber := Object()
RegExNeedle_final = i)_final
complexRegExNeedle_num = (?i)(?<!library_|lib_|[\.xX0-9])([0-9]{5})(?![xX\.0-9])	; Any group of five consecutive digits not preceded or followed by the characters . - x and X (which are used for electric sheep and filenames that list dimensions as NxN, and files named from Filter Forge libraries, *and* filenames that have more than 5 consecutive numbers, all of which otherwise would produce false positive matches).
		; Reference, string negation in pcre: https://www.ibm.com/developerworks/community/blogs/HermannSW/entry/how_to_not_match_something_with_pcre8?lang=en
;RegExNeedle_num = ([0-9]{5})
probRegExNeedle_num = i)[0-9]{6,}
possProbTagRegex = variant
badMatchBool = 0
badFileNameFoundBool = 0

; FUNCTION: get parent directory for a given full path and filename string.
; Figure out the parent folder name:
getParentDir(fullPathToFile) {
StringSplit, directoriesAboveFilesArray, fullPathToFile, \
Loop, %directoriesAboveFilesArray0%
	{
	this_check := directoriesAboveFilesArray%a_index%
	usedIndex = %a_index%
	}
usedIndex -= 1
fileParentDir := directoriesAboveFilesArray%usedIndex%	; That stores the parent folder name in fileParentDir.
return fileParentDir
}

; FUNCTION: help message.
help() {
	MsgBox, This program should be run from the command-line, and it expects three parameters, and they must be in a specific order, e.g.:`n`nfileLabelAndNumber.ahk D:\Some\DirectoryWithFilesToNumber _tag_ [Yes]`n`nThe third argument is optional. See README.md for details.
	exit
}

; Assign values passed from command line to local variables (or assign nothing to them, if nothing was passed).
argOne = %1%	; Path to scan
argTwo = %2%	; File tag to apply
argThree = %3%		; If this argument is supplied in any form (it doesn't have to be the word "yes," files will be renamed (instead of only creating logs specifying what would be renamed).

if (!argOne) {
help()
}

if (!argTwo) {
help()
}

; Initialize fileNamesArray with all full paths of scanned files.
Loop, %1%\*.*, 0, 1
	{
	fileNamesArray.Insert(A_LoopFileFullPath)
			; Command used to create test directory full of duplicate although zero-length files: ROBOCOPY "\\dumbledore\d$\Alex\Art\_Abstractions series" C:\Users\Tia\Desktop\Alex\_artDev\testDir /E /MT:8 /CREATE
	}
; === END GLOBALS


; === FIND HIGHEST NUMBERED FILE
; === HIGHEST FILE NUMBER COUNT, AND
; FILE EXTENSION FILTER, of fileNamesArray (with *all* files) down to the extensions we care about, and store them in baseIndexSearchArray.
; MEANWHILE, NARROW fileNamesArray DOWN to only include paths going to file extensions we care about. 05/19/2015 09:47:41 PM -RAH
; ALSO MEANWHILE, isolate and report any problem file names that would result in erroneous numbering.

FileDelete, %argOne%\AllFileNamesBeforeFiltering.txt
FileDelete, %argOne%\AllFileNamesAfterFiltering.txt
FileDelete, %argOne%\numberedMatches.txt
FileDelete, %argOne%\unusedBadMatches.txt
FileDelete, %argOne%\fileNumberingSearchLog.txt
sleep, 340
for index, element_fileNamesArray in fileNamesArray
{
SplitPath, element_fileNamesArray, , , fileExtension
for index2, element2 in searchExtensions
	{
	if (fileExtension == element2) {
		SplitPath, element_fileNamesArray, fileName
		SplitPath, element_fileNamesArray,, fileDir
		; WAIT TO INSERT into arrays until after potential bad file name checks . . .

		; POSSIBLE BAD MATCHES--DISCARD
		; Check for potentially bad number file name and store any result to warn user.
		badMatchBool := RegExMatch(fileName, probRegExNeedle_num, needleRegExMatch)
		if (badMatchBool != 0) {
			badFileNameFoundBool = 1
			appendStr = DIRECTORY:`n%fileDir%`nPOSSIBLE PROBLEM NUMBER FILE:`n%fileName%`n-- flagged as potentially causing bad highest number match, for %needleRegExMatch%`n`n
			FileAppend, %appendStr%, %argOne%\unusedBadMatches.txt
			}

		; POSSIBLE BAD MATCHES--DISCARD
		; Check for potentially bad tag file name and store any result to warn user.
		badMatchBool := RegExMatch(fileName, possProbTagRegex, needleRegExMatch)
		if (badMatchBool != 0) {
			badFileNameFoundBool = 1
			appendStr = DIRECTORY:`n%fileDir%`nPOSSIBLE PROBLEM OR IGNORE TAG FILE:`n%fileName%`n-- flagged as potentially causing bad file number match because of file name tag, for %needleRegExMatch%`n`n
			FileAppend, %appendStr%, %argOne%\unusedBadMatches.txt
					; TESTING ONLY--COMMENT OUT IN PRODUCTION:
					; thisSize := baseIndexSearchArray.MaxIndex()
					; thisString := baseIndexSearchArray[%thisSize%]
					; MsgBox, thisSize val is: %thisSize%, with val of item:`n%thisString%`n`nvia matchFoundBool val: %matchFoundBool%`n`n--and regex match val:`n%needleRegExMatch%`n`n--from element:`n%element_fileNamesArray%
			}

		if (badFileNameFoundBool == 0) {
		tempArray.Insert(element_fileNamesArray)
			; GOOD MATCHES--KEEP
			; Check whether the file is numbered, and stores that (in the array baseIndexSearchArray) for sorting by highest :
			matchFoundBool := RegExMatch(fileName, complexRegExNeedle_num, needleRegExMatch)
			if (matchFoundBool != 0) {
				baseIndexSearchArray.Insert(needleRegExMatch)
				appendStr = DIRECTORY:`n%fileDir%`nFILE:`n%fileName%`n-- caused numbered file match for %needleRegExMatch%`n`n
				FileAppend, %appendStr%, %argOne%\numberFileRegexMatchesLog.txt
				}
			}
		badFileNameFoundBool = 0
		}
	}
}

; What do we have now? Read on . . . 
; Copy that extension-filtered tempArray back over fileNamesArray (which the remainder of this script relies on). NIGGLE: That could only happen with tempArray being global.
fileNamesArray := tempArray
; Reinitilize (free memory of) tempArray.
tempArray := "[Booyeah], [Grandma]"
		; TESTING ONLY--COMMENT OUT IN PRODUCTION:
		;for idxOne, elementTwo in fileNamesArray
		;{
		;FileAppend, %elementTwo%`n, %argOne%\AllFileNamesAfterFiltering.txt
		;}

; END ALSO MEANWHILE, isolate and report any problem file names that would result in erroneous numbering.
; END MEANWHILE, NARROW fileNamesArray DOWN to only include paths going to file extensions we care about.
; === END HIGHEST FILE NUMBER COUNT


; === STORE HIGHEST NUMBER FOUND among number files in the variable baseIndex (scanning array baseIndexSearchArray).
; Identify the highest number among numbered files, and store it in the global variable baseIndex.
; Also, write all found nums, and mention it.
FileDelete, %argOne%\highestNumberedFileNumFoundLog.txt
sleep, 340
for index, element_baseIndexSearchArray in baseIndexSearchArray
	{
	if (baseIndex < element_baseIndexSearchArray) {
		baseIndex = %element_baseIndexSearchArray%
		FileAppend, INCREASED HIGHEST FOUND number count to %element_baseIndexSearchArray%`n, %argOne%\fileNumberingSearchLog.txt
		}
	}
MsgBox, Search for highest numbered file complete. Highest numbered file found by search criteria is %baseIndex%. You may wish to check the following log files for any errors:`n`n%argOne%\numberFileRegexMatchesLog.txt`n`n%argOne%\unusedBadMatches.txt`n`nThe former logs all matches for the believed (intended) highest numbered file. The latter logs all believed bad number and file tag name matches which will be ignored.
; === END STORE HIGHEST NUMBER FOUND among number files . . . and mention it.


; WE NOW HAVE:
	; baseIndex, a variable
		; --WHICH tells us the highest number among numbered files, and:
	; baseIndexSearchArray
		; -- an array of all numbers in numbered files (from which we will find the highest), and--
	; fileNamesArray
		; --AN ARRAY of all paths and filenames of the extensions we care about.

; === END HIGHEST FILE NUMBER COUNT, AND
; FILE EXTENSION FILTER, of fileNamesArray (with *all* files) down to the extensions we care about.

; === START CHECK all file/container folder names in fileNamesArray, and do things with them:
fileParentDir=
folderHasNumberBool = 1
folderHasFinalBool = 0
for index, element_fileNamesArray in fileNamesArray
{
; Get FILE without path:
SplitPath, element_fileNamesArray, fileName

; Use a function that returns the parent directory for a given full path and file name string:
fileParentDir := getParentDir(element_fileNamesArray)

; Check if folder is numbered; store is/not in a bool.
folderHasNumberBool := RegExMatch(fileParentDir, complexRegExNeedle_num)

; If the parent folder has the label _final, store it in an array of paths/files to be numbered/renamed.
folderMatchesRegEx_final := RegExMatch(fileParentDir, RegExNeedle_final)

; If the folder isn't numbered, and has the label _final, add the filename (here from element_fileNamesArray), with its path, to the array filesOrPathsToRenumber.
if (folderHasNumberBool == 0 && folderMatchesRegEx_final == 1) {
	filesOrPathsToRenumber.Insert(element_fileNamesArray)
	}
	; Files in this array will all be numbered. This array may not be finished at this point; via use of the array candidateNumberingFiles we will fill it.

if (folderHasNumberBool == 0 && folderMatchesRegEx_final == 0) {
	candidateNumberingFiles.Insert(element_fileNamesArray)
	; Files in this array will be filtered for numbering candidacy, then numbered (by order of creation date).
	}
}

	; Ascertain which files shall be renamed and how.
fileIsNumberedBool = 0
fileIsLabeledFinalBool = 0
for index, element in candidateNumberingFiles
	{
	SplitPath, element, renameFileCandidate		; NOTE: renameFileCandidate is only for regex to identify if file should be rename-numbered; element (full path and file name) gets put into filesOrPathsToRenumber if so.
			fileIsNumberedBool := RegExMatch(renameFileCandidate, complexRegExNeedle_num, isThisFileNameNumbered)
			fileIsLabeledFinalBool := RegExMatch(renameFileCandidate, RegExNeedle_final)
		if (fileIsNumberedBool == 0 && fileIsLabeledFinalBool != 0) {
		filesOrPathsToRenumber.Insert(element)
		}
	}

;CONTINUE HERE
	
filesToNumberTimeStampPrefixedArray := Object()
for index, fileName in filesOrPathsToRenumber
{
FileGetTime, fileTime, %fileName%, C	; Retrieve files' time of creation
	; === PREFIX ELEMENTS IN filesOrPathsToRenumber with timestamp (e.g. 20150207074600) and bar character | to use like a key/value array by splitting the string on | while sorting/renaming by index:
fileNameAndTimeStampString=%fileTime%|%fileName%
filesToNumberTimeStampPrefixedArray.Insert(fileNameAndTimeStampString)
}

	; === INSERTION SORT (manual coded as I couldn't find a function for arrays that worked for me--or I didn't know how to use any) ; Adapted from reference code found at: https://github.com/acmeism/RosettaCodeData/blob/master/Task/Sorting-algorithms-Insertion-sort/AutoHotkey/sorting-algorithms-insertion-sort.ahk
arrayCount := filesToNumberTimeStampPrefixedArray.MaxIndex()
Loop %arrayCount% {
	i := A_Index, v := filesToNumberTimeStampPrefixedArray[i], j := i-1
	While j>0 and filesToNumberTimeStampPrefixedArray[j]>v
		u := j+1, filesToNumberTimeStampPrefixedArray[u] := filesToNumberTimeStampPrefixedArray[j], j--
	u := j+1, filesToNumberTimeStampPrefixedArray[u] := v
}
	; === END INSERTION SORT

	; === THE RIDICULOUSLY NAMED ARRAY filesToNumberTimeStampPrefixedArray IS SORTED BY CREATION DATE STAMP, and we will do stuff with it (see later comments . . .)
; === END FINAL PREPARATIONS FOR RENAMING!


; ====== RENAMING! ======
; === ERROR CHECK OR ELSE NO RUN!
; CHECK FOR DUPLICATE FILE NAMES with different extensions and log them if they exist, notify user of log, then exit.
FileDelete, %argOne%\fileLabelAndNumber_error_log.txt
Sleep, 244
loop_count = 0
lastSeenFileNameNoExt =
duplicateFileNameEncounteredBool = 0
for index, supaString in filesToNumberTimeStampPrefixedArray
{
StringSplit, stringsSplitPseudoArray, supaString, |
fileAndPath = %stringsSplitPseudoArray2%
SplitPath, fileAndPath, fileName
SplitPath, fileAndPath,,,, fileNameNoExt		; File name without extension
SplitPath, fileAndPath,, fullDirPath
SplitPath, fileAndPath,,, fileExtension
fileParentDir := getParentDir(fileAndPath)
if (lastSeenFileNameNoExt == fileNameNoExt)
	{
	duplicateFileNameEncounteredBool = 1
	;MsgBox, Duplicate file names with different extensions found!`n%fileNameNoExt%.%fileExtension%`n%lastSeenFileNameNoExt%.%lastSeenFileFileExt%
	fileAppend, _____________IN FOLDER:`t%fullDirPath%`n_____CURRENT FILE NAME:`t%fileNameNoExt%.%fileExtension%`nDUPLICATE W/DIFF. EXT.:`t%lastSeenFileNameNoExt%.%lastSeenFileFileExt%`n`n, %argOne%\fileLabelAndNumber_error_log.txt
	}
lastSeenFileNameNoExt = %fileNameNoExt%
lastSeenFileFileExt = %fileExtension%
}

if (duplicateFileNameEncounteredBool == 1)
	{
	MsgBox, 0, Duplicate file name problem!, === OH TEH NOES! ===`n`nPlease see %argOne%\fileLabelAndNumber_error_log.txt`n`n--and correct duplicate file name errors (files with the same name but different file extensions). I won't do any renaming until those problems are fixed.
	;Exit
	}
; === END ERROR CHECK OR ELSE NO RUN!

; TO DO: METHOD UPDATE IDEA: Lump all files to be renamed into one array, then number them all, then any that are numbered but don't have the label _final, add that label. So much simpler than the loopdy-loops I've been doing segregating files into two arrays. 05/20/2015 01:14:29 PM -RAH
	; DONE. 05/20/2015 05:02:32 PM -RAH

; NOTE: %baseIndex% stores the highest number found of numbered files.
SetFormat, float, 05.0	; That sets the numbering to be five-digit, with leading zeros if necessary--which I want in my numbering scheme. Oddly, to print a numeric value with padding, it must be stored as an integer, even if there is only a zero after that integer (e.g. 21.0)

FileDelete, %argOne%\file_label_and_number_Log.txt
Sleep, 244
filesToNumberTimeStampPrefixedArraySize := filesToNumberTimeStampPrefixedArray.MaxIndex()
loop_count = 0
wasErrorDuringRenamesBool = 0
lastSeenFileNameNoExt = ""
fileRenameNoExtString = ""	;Dunno if needs to be declared outside the following loop--not checking.
fileRenameStringFullPath = ""			; "
fileRenamed = ""						; "

; Figure and log proposed file name changes.
for index, supaString in filesToNumberTimeStampPrefixedArray
{
loop_count += 1
	; Since the array is sorted now, strip off the date stamps and | from the strings in the array, as those were only for sorting purposes. But we may want those to put into EXIF data...
; TO DO? Add something that records the creation time stamp into something external to the file, and/or stores it in appended EXIF data?
	; Strip off the timestamp and bar | prefix:
StringSplit, stringsSplitPseudoArray, supaString, |
	; NOT YET USED, if it ever will be: timeStamp = %stringsSplitPseudoArray1%
fileAndPath = %stringsSplitPseudoArray2%
SplitPath, fileAndPath, fileName
SplitPath, fileAndPath,,,, fileNameNoExt		; File name without extension
SplitPath, fileAndPath,, fullDirPath
SplitPath, fileAndPath,,, fileExtension
fileParentDir := getParentDir(fileAndPath)
		; TESTING ONLY--COMMENT OUT IN PRODUCTION:
		;MsgBox, baseIndex val before increment: %baseIndex%
baseIndex += 1.0
; ref: NewStr := RegExReplace(Haystack, NeedleRegEx [, Replacement = "", OutputVarCount = "", Limit = -1, StartingPosition = 1])
replStr = _final%argTwo%%baseIndex%_
fileRenameNoExtString := RegExReplace(fileNameNoExt, RegExNeedle_final, replStr, outVarCount)
; If there were no replacements made via that RegExReplace function call, outVarCount will have a value of 0, which tells us we're looking at a file name in a folder which has the tag _final in the folder name, which per our protocol is an indicator to number and tag all files in that folder. In that case prefix the file name with _final_%baseIndex%%argTwo% (argTwo being the tag specified as parameter 2), otherwise use the return from the regex replace call (which tags and number it after the regex max) and add the file extension.
if (outVarCount == 0) {
	fileRenamed = _final%argTwo%%baseIndex%__%fileName%
	} else {
	fileRenamed = %fileRenameNoExtString%.%fileExtension%
	}
fileRenameStringFullPath = %fullDirPath%\%fileRenamed%
		; MsgBox, value of renamed with full path is:`n%fileRenameStringFullPath%
; THIS IS WHERE THE ERROR SHOWS:
FileAppend, _____________IN FOLDER:`t%fullDirPath%`n_____CURRENT FILE NAME:`t%fileName%`nPROPOSED NEW FILE NAME:`t%fileRenamed%`n`n, %argOne%\file_label_and_number_Log.txt

; HERE GOES RENAMING!
if (!argThree)
	{
	if (loop_count == filesToNumberTimeStampPrefixedArraySize)
		{
;TO DO: UNCOMMENT THE FOLLOWING FOR FINAL USE:
		MsgBox, 0,Tagged file renaming, A list of proposed file renames is written to the file:`n`n%argOne%\file_label_and_number_Log.txt`n`nReview that file to catch any undesirable proposed renames.`n`nIf everything looks right then you are ready to run the program again from the command-line with a third parameter`, being the string "yes" (See README.md if that confuses you). If you run this with the third parameter "yes," after you click the Ok button here`, all of the files will be renamed as detailed in that log file. Also`, that log file will be copied to a new file named with a date stamp (for when this was done) detailing all changes (in case`, further down the road`, you need to revert any changes`, and need a reference for what on earth happened :)`n`nIf you are confused by this message, see README.md.
		}
	}

	; Reference: MsgBox [, Options, Title, Text, Timeout]
if (argThree && duplicateFileNameEncounteredBool == 0)
	{
	; DO THE ACTUAL RENAMING! -- which is done according to changing variables in this loop.
			; TESTING ONLY--COMMENT OUT IN PRODUCTION:
			; MsgBox, Command will be:`n`nFileMove, %stringsSplitPseudoArray2%, %fileRenameStringFullPath%
	; ref: FileMove, SourcePattern, DestPattern [, Flag]
	FileMove, %stringsSplitPseudoArray2%, %fileRenameStringFullPath%
		if (ErrorLevel) {
			FileAppend, FILE ERROR related to rename of:`n%stringsSplitPseudoArray2%`n--TO:%fileRenameStringFullPath%`n, %argOne%\fileLabelAndNumber_error_log.txt
			wasErrorDuringRenamesBool = 1
			}
	}
}
; === END RENAMING!

; === Copy renaming log to new file (with altered text indicating changes were made, not merely proposed).
if (argThree && duplicateFileNameEncounteredBool == 0)
	{
	FileRead, fileReadString, %argOne%\file_label_and_number_Log.txt
	modifiedFileReadString := RegExReplace(fileReadString, "PROPOSED NEW FILE NAME", "____________RENAMED TO")
	FormatTime, time,, yyyy-MM-dd__hh.mm.ss_tt
	;Send %time%
	FileAppend, %modifiedFileReadString%, %argOne%\%time%_file_label_and_number_Log.txt
	}

; === FINIS!
if (wasErrorDuringRenamesBool != 0) {
	MsgBox, 0, Rename error, === OH TEH NOES! ===`n`nFile rename error! Please see %argOne%\fileLabelAndNumber_error_log.txt --if it is even helpful, which it might not be.
	}

; TO DO: code it to rename directories!

MsgBox, Floofy-floo!

return




/* Overly many notes copied into a comment block:
Make good documentation.

TO DO? : Add notes to documentation:

NOTE: For this program to work as intended, you must follow the rules of naming files after this convention:
Offset the files you want counted with dashes or underscores (- or _). (It may be ok not to do this if the number is at the start of a filename.) Do not prefix the first underscore with the word "Library" or "Lib" (as some names generated from my batch scripts for Filter Forge do), and do not prefix or postfix the characters period or x (. or x or X).

I've tested whether files with the label _final in folders that also have that label will be numbered twice, and that seems not to be the case. But don't arrange your files that way--that's bad practice!
Five-digit numbered files might not be found by the program unless they are surrounded by - or _ characters. ALSO, warn that if there are numbers in folders other than the intended sorting five-digit numbers, it could mess up the folder names in ways the user doesn't want.

NOTE: To make use of this, art files which are finalized and ready for publication must be named beginning with _FINAL or _final (case doesn't matter). The script will sort and rename finalized works (so named) by date of creation.

(For the as-yet undescribed foldo mojo, that must also be _final)
*/
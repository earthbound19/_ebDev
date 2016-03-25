#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; PROTOTYPE control block: only run an inner loop once if a condition is met; otherwise run it as normal.

soughtDirectory=
checkedDirectory=
fileNamesArray := Object()

MsgBox, Value of parameter 1 is %1%.

; NOTE: For this script to work, you must pass a valid path to it (with sub-folders and files to list) as the first parameter!
Loop, %1%\*.tif, 0, 1
	{
	fileNamesArray.Insert(A_LoopFileFullPath)
	}

for index, element in fileNamesArray
{
MsgBox, Start of outer loop for value %element%.
if (checkedDirectory = "") {
	MsgBox, checkedDirectory equals null.
	soughtDirectory = notNull
	}
	else {
	MsgBox, checkedDirectory value is %checkedDirectory%.
	}

if (soughtDirectory != "" && checkedDirectory = "") {
	; NOTE: still using the RegExNeedle defined earlier in the following, AND create an important check var:
	MsgBox, Doing stuff in inner loop.
	; NOTE: assigned while checkedDirectory is not blank! :
	checkedDirectory = soughtDirectory
	soughtDirectory =
	; NOTE: to make this run the inner loop as normal, comment out the above two lines, and uncomment the below line.
	; checkedDirectory=
	}
MsgBox, End of outer loop.
}
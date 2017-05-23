;IMPORTANT NOTE: this script may not work if there are spaces in folder and file names! Put underscores in place of those in your entire path, and in all file names. Unless I find a fix for that.

#NoEnv
SetWorkingDir %A_ScriptDir%

;TO DO: Duplicate work protecting -- no overwrite existing files, and notify other processes of render.
;TO DO: Add ability to change work directory for flexibility e.g. to change to a path passed as %1.
workDir = %A_ScriptDir%
whetherHide = Hide
colorPairsList = %workDir%\colorPairs.txt
colorPairsArray := Object()
	Loop, Read, %colorPairsList%
	{
		colorPairsArray.Insert(A_LoopReadLine)
	}
colorPairsArraySize := colorPairsArray._MaxIndex()

Loop, %workDir%\*.png
{
	FileDelete, %workDir%\bwRecolorBatch.bat

	FileAppend ,nconvert -out bmp -overwrite -canvas #10 #10 center -bgcolor 0 0 0 %A_LoopFileName%`n`n, %workDir%\bwRecolorBatch.bat
		; Reference to split a string into separate variables by a delimiter:  http://www.autohotkey.com/board/topic/22627-split-string-into-individual-caharacters/?p=429810

	temp = %A_LoopFileName%
	SplitPath, temp,,,, fileNoExt	; Puts the filename without the extension in temp
	traceFile = %fileNoExt%.bmp
	FileAppend ,potrace -n -s --group -r 72 -C #010101 --fillcolor #efefef %traceFile%`n`n, %workDir%\bwRecolorBatch.bat

	outDir = %workDir%\%fileNoExt%_result
	FileAppend, MKDIR %outDir%`n`n, %workDir%\bwRecolorBatch.bat

	tracedSVGfile = %fileNoExt%.svg
	;TO DO: change it so that outDir will adapt to a base directory passed to it by %1% (per earlier note). Until then, it defaults to where this script/executable will be run from, which is the base path %A_ScriptDir%, as that was earlier assigned to workDir.

	FileAppend, COPY %workDir%\%tracedSVGfile% %outDir%\%fileNoExt%.svg && DEL %fileNoExt%.bmp, %workDir%\bwRecolorBatch.bat

	RunWait, %comspec% /C "%workDir%\bwRecolorBatch.bat", %workDir%, %whetherHide%
	;Sleep, 100

		;I can change the xml in the .svg plain-text file to recolor it. Sheesh.
		for colorPairsArraySize, colorPair in colorPairsArray
		{
		StringSplit, color, colorPair, `,
				; MsgBox, bgHex_%color1%_fill_hex%color2%
		FileRead, svgXMLcontentString, %outDir%\%fileNoExt%.svg
				; MsgBox, svgXMLcontentString value is:`n`n%svgXMLcontentString%
		StringReplace, tempString, svgXMLcontentString, #010101, #%color1%, UseErrorLevel
				; MsgBox, new val is:`n`n%tempString%
		StringReplace, svgXMLcontentString, tempString, #efefef, #%color2%, UseErrorLevel
				; MsgBox, new val is:`n`n%svgXMLcontentString%
		FileDelete, %outDir%\%A_LoopFileName%_bg_hex%color1%_fill_hex%color2%.svg
		FileAppend, %svgXMLcontentString%, %outDir%\%A_LoopFileName%_bg_hex%color1%_fill_hex%color2%.svg
		}

FileDelete, %workDir%\%tracedSVGfile%
}
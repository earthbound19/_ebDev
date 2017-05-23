; makehueedVariantImages.ahk, 05/27/2015 02:01:58 PM -RAH
; I release this script to the public domain. Dependencies: the Windows operating system, and the FOSS AutoHotkey and nconvert, which must both be in your %PATH%.
;
; This script produces many hue shift and desaturation variants, of any images in a directory passed to it (as a command-line parameter), using nconvert. This means that you may drag and drop a folder of images onto this script file to create hue and saturation shift variants for every image in that folder. It outputs the variants in subfolders named after the original, with the hs adjustment values noted in the file names.
; USAGE: this script expects one parameter, which is a directory to scan, e.g.:
;
; makehueedVariantImages.ahk scanDirectory
;
; NOTE: The suggested hue shift values for HSL-hueShiftValues.txt (offered as comments at the end of this script) were created assuming a predominantly blue image. I suggest that to create the widest color variety of variants, you copy any images (which you wish to create variants from) into a new folder, and then manually hue-shift each of them to be predominantly blue, and then run this script on the folder where you have those blue-shifted images stored (and you may want to scale them down to large preview sizes if your images are very high resolution, to more quickly screen what you do and don't want to keep). Also, this script assumes output in the .png image format. Lastly, this script may not work if there are spaces in folder and file names! Put underscores in place of those in your entire path, and in all file names. Unless I find a fix for that.

#NoEnv
;#SingleInstance force
SetWorkingDir %A_ScriptDir%

;MsgBox, 1, WARNING!, Back up your files before running this script, or operate on a copy of your files in a separate folder tree! If something goes wrong, it could irrecoverably damage or delete them! If your files are backed up, click OK. Otherwise click Cancel.
	IfMsgBox, OK
		goto SCRIPT_START
	IfMsgBox, Cancel
		Exit

SCRIPT_START:
;GLOBALS:
scanDir = %1%
whetherHide = Hide
hueValuesArray := Object()
satValuesArray := Object()

Loop, Read, %A_ScriptDir%\HSL-hueShiftValues.txt
{
	hueValuesArray.Insert(A_LoopReadLine)
}

Loop, Read, %A_ScriptDir%\HSL-saturationShiftValues.txt
{
	satValuesArray.Insert(A_LoopReadLine)
}

SetFormat, float, 02.0	; Allows for leading zeros in file numbering.
;Loop, %scanDir%\*.png, 0, 1		; Option: don't retrieve folder names, do recurse subfolders. Leads to redundant scanning of result folders if run over the same folder again, while no new variants are rendered in those subfolder-named folders in the root folder :/

Loop, %scanDir%\*.png
{
temp = %A_LoopFileName%
SplitPath, temp,,,, InNameNoExt
variantOutputDir = %scanDir%\%InNameNoExt%_variants
FileCreateDir, %variantOutputDir%
variantCount = 0

				; Render one completely desaturated variant for every image; assume user includes no such val. value in sat. val. list.
						; If this were an Important Program, I'd make this a function (repeating code here). Meanwhile, meh.
				renderBool = 1
				variantCount += 1.0
				fileName = %A_LoopFileName%
				SplitPath, fileName, InFileName
				SplitPath, fileName,,,, InNameNoExt
				renderFileName = %variantOutputDir%\%InNameNoExt%_variant%variantCount%_ncv-HLS%hue%_0_-127.png
				; renderingFileStubName = %variantOutputDir%\%InNameNoExt%_variant%variantCount%_ncv-HLS_%hue%_0_-127.rendering
				renderingFileStubName = %variantOutputDir%\%InNameNoExt%_ncv-HLS_%hue%_0_-127.rendering
						if FileExist(renderFileName) {
						renderBool == 0
						}
						if FileExist(renderingFileStubName) {
						renderBool == 0
						}
					if (renderBool == 1) {
					; Note the tweaks from the copy of this code further below that makes sat. -127, but leaves hue alone (at 0):
					command = nconvert -overwrite -keepfiledate -hls 0 0 -127 -out png -o %renderFileName% %scanDir%\%InFileName%
					FileAppend,, %renderingFileStubName%
					RunWait, %comspec% /C "%command%", %A_ScriptDir%, %whetherHide%
					FileDelete, %renderingFileStubName%
					Sleep, 250		; Because these scripts can run faster than Windows registers file deletions.
					}
	for hueIndex, hue in hueValuesArray
	{
	
		for satIndex, sat in satValuesArray
		{
		renderBool = 1
		variantCount += 1.0	; Adding a decimal point in the variable makes it present as a digit with n leading 0s (as set with SetFormat earlier). Also, this will make it start with the number two, which will be accurate (as the original file is considered variant one, and the first variant is considered variant 02).
		fileName = %A_LoopFileName%
				; Reference:
				; SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
		SplitPath, fileName, InFileName
		SplitPath, fileName,,,, InNameNoExt
		; renderFileName = %variantOutputDir%\%InNameNoExt%_variant%variantCount%_ncv-HLS%hue%_0_%sat%.png
		; renderingFileStubName = %variantOutputDir%\%InNameNoExt%_variant%variantCount%_ncv-HLS_%hue%_0_%sat%.rendering
		renderFileName = %variantOutputDir%\%InNameNoExt%_ncv-HLS%hue%_0_%sat%.png
		renderingFileStubName = %variantOutputDir%\%InNameNoExt%_ncv-HLS_%hue%_0_%sat%.rendering
				; I tried a compound statement like the following:
				; if ( (if FileExist(fileName)) | (if FileExist(otherFileName)) ) { do stuff } 
				; -- which did not work. Therefore the following if blocks and bool mess. 05/27/2015 05:37:10 PM -RAH
				if FileExist(renderFileName) {
				renderBool == 0
				}
				if FileExist(renderingFileStubName) {
				renderBool == 0
				}
			if (renderBool == 1) {
			; Template command: nconvert -overwrite -keepfiledate -out png -l filelist.txt -o outfilename.png -hls -47 0 0 inputFileName.png
			; ADD to that: -ratio -resize 720 -rtype lanczos
			command = nconvert -overwrite -keepfiledate -hls %hue% 0 %sat% -out png -o %renderFileName% %scanDir%\%InFileName%
					; MsgBox, command is:`n`n%command%
			FileAppend,, %renderingFileStubName%
			RunWait, %comspec% /C "%command%", %A_ScriptDir%, %whetherHide%
			FileDelete, %renderingFileStubName%
			Sleep, 250		; Because these scripts can run faster than Windows registers file deletions.
			}
		}
	}
}

;MsgBox, Done.

; SUGGESTED HUE SHIFT VALUES LIST
/* You may copy and paste the following list into a plain text file named HSL-hueShiftValues.txt, which must be in the same directory where this script resides.
--

-7
-13
-20
-34
-37
-41
-45
-51
-64
46
44
41
37
33
31
30
28
24
15
8

The following list is a suggestion for HSL-saturationShiftValues.txt (which is also necessary); note that this script will automatically make only one completely desaturated variant for every image it scans (it would be redundant, otherwise, to have -127 in the sat. list, and have it make an identical completely desaturated variant for every hue shift).

0
-32
-63

--
OTHER NOTES:
I found a multiplier constant that will convert all photoshop hue shift values to their exact equivalent in nconvert (which you can't enter exactly in nconvert, as it uses integers and not floats). That constant is:

0.285714285714286

e.g. if you use the HSL filter in Photoshop with a hue shift value of -164, multiply that by the above constant for an equivalent nconvert hue shift value of -46.85 (round that to 47).

*/

; TO DO: examine imagemagick -remap filename parameter:      transform image colors to match this set of colors!
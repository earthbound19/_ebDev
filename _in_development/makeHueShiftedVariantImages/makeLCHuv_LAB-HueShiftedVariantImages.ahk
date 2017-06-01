; DESCRIPTION: produces many hue shift and desaturation variants (using the LCHuv colorspace for conversion) of any images in a directory passed to it (as a command-line parameter), using imagemagick (convert). This means that you may drag and drop a folder of images onto this script file to create hue and saturation shift variants for every image in that folder, with possibly more perceptually-friendly color changes than RGB color shifting. It outputs the variants in subfolders named after the original, with the hue and saturation adjustment values noted in the file names.

; LICENSE: I release this script to the public domain. 05/27/2015 02:01:58 PM -RAH

; DEPENDENCIES: the Windows operating system, and the FOSS AutoHotkey and imagemagick, which must both be in your %PATH%. Moreover, owing to a program name conflict on Windows, imagemagick's convert.exe must be renamed to imagemagick_convert.exe (or, this script expects that).

; USAGE: this script expects one parameter, which is a directory to scan, e.g.:
;
; makeLCHuv_LAB-HueShiftedVariantImages.ahk.ahk scanDirectory
;
; IMPORTANT NOTES: The suggested hue shift values for hueShiftValues.txt (offered as comments at the end of this script) were created assuming a predominantly blue image. I suggest that to create the widest color variety of variants, you copy any images (which you wish to create variants from) into a new folder, and then manually hue-shift each of them to be predominantly blue, and then run this script on the folder where you have those blue-shifted images stored (and you may want to scale them down to large preview sizes if your images are very high resolution, to more quickly screen what you do and don't want to keep). Also, this script assumes output in the .png image format. Lastly, this script may not work if there are spaces in folder and file names! Put underscores in place of those in your entire path, and in all file names. Unless I find a fix for that.

; TO DO: Update to operate on all compatible image formats in a directory (instead of assuming and only working on .png images).

#NoEnv
#SingleInstance force
SetWorkingDir %A_ScriptDir%

MsgBox, 1, WARNING!, Back up your files before running this script, or operate on a copy of your files in a separate folder tree! If something goes wrong, it could irrecoverably damage or delete your files! If your files are not backed up, click Cancel. Otherwise, click OK. NOTE: This script will attempt to make variations for every file in a directory, whether the file is an image or not. Other file types in a directory may slow it down unecessarily.
	; IfMsgBox, OK
		; goto SCRIPT_START
	; IfMsgBox, Cancel
		; Exit

SCRIPT_START:
;GLOBALS:
scanDir = %1%
whetherHide = Hide
hueValuesArray := Object()
HSLvals_element := Object()

Loop, Read, %A_ScriptDir%\LAB_hueShiftValues.txt
{
	hueValuesArray.Insert(A_LoopReadLine)
}

SetFormat, float, 02.0	; Allows for leading zeros in file numbering.
Loop, %scanDir%\*.*
{
temp = %A_LoopFileName%
SplitPath, temp,,,, InNameNoExt
variantOutputDir = %scanDir%\%InNameNoExt%_lab_HSL_variants
FileCreateDir, %variantOutputDir%
variantCount = 0

				; Render one completely desaturated variant for every image; assume user includes no such value in sat. val. list.
						; If this were an Important Program, I'd make this a function (repeating code here). Meanwhile, meh.
				renderBool = 1
				variantCount += 1.0
				fileName = %A_LoopFileName%
				SplitPath, fileName, InFileName
				SplitPath, fileName,,,, InNameNoExt
				renderFileName = %variantOutputDir%\%InNameNoExt%_variant%variantCount%_ncv-HLS%hue%_0_-127.png
				renderingFileStubName = %variantOutputDir%\%InNameNoExt%_variant%variantCount%_ncv-HLS_%hue%_0_-127.rendering
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
	; ref: StringSplit, OutputArray, InputVar [, Delimiters, OmitChars]
	StringSplit, HSLvals_element, hue, `,
	lab_A = %HSLvals_element1%
	lab_B = %HSLvals_element2%
	lab_C = %HSLvals_element3%
		; MsgBox, vals:`n`n HSLvals_element[1] is %lab_A%`n`nvals:`n`n HSLvals_element[2] is %lab_B%`n`nvals:`n`n HSLvals_element[3] is %lab_C%
	renderBool = 1
	variantCount += 1.0	; Adding a decimal point in the variable makes it present as a digit with n leading 0s (as set with SetFormat earlier). Also, this will make it start with the number two, which will be accurate (as the original file is considered variant one, and the first variant is considered variant 02).
	fileName = %A_LoopFileName%
			; Reference:
			; SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
	SplitPath, fileName, InFileName
	SplitPath, fileName,,,, InNameNoExt
	renderFileName = %variantOutputDir%\%InNameNoExt%_variant%variantCount%_LCHuv-LAB_%lab_A%_%lab_B%_%lab_C%.png
	renderingFileStubName = %variantOutputDir%\%InNameNoExt%_variant%variantCount%_LCHuv-LAB_%lab_A%_%lab_B%_%lab_C%.rendering
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
; Template command, where the three values to modulate are (respectively) brightness, saturation, and hue; 100 = no change, and changes range from 0 to 200:
; imagemagick_convert -define modulate:colorspace=LCHuv -modulate 100,100,25 C:\imageFolder\inputImage.png C:\imageFolder\variants\result.png
		command = imagemagick_convert -define modulate:colorspace=LCHuv -modulate %lab_A%,%lab_B%,%lab_C% %scanDir%\%InFileName% %renderFileName%
				; MsgBox, command is:`n`n%command%
				FileAppend, %command%`n`n, commands.txt
		FileAppend,, %renderingFileStubName%
		RunWait, %comspec% /C "%command%", %A_ScriptDir%, %whetherHide%
		FileDelete, %renderingFileStubName%
		Sleep, 250		; Because these scripts can run faster than Windows registers file deletions.
		}
	}
}

MsgBox, Done.

; SUGGESTED HUE SHIFT VALUES LIST
/* You may copy and paste the following list into a plain text file named hueShiftValues.txt, which must be in the same directory where this script resides.
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

The following list is a suggestion for saturationShiftValues.txt (which is also necessary); note that this script will automatically make only one completely desaturated variant for every image it scans (it would be redundant, otherwise, to have -127 in the sat. list, and have it make an identical completely desaturated variant for every hue shift).

0
-32
-63

--
OTHER NOTES:
I found a multiplier constant that will convert all photoshop hue shift values to their exact equivalent in nconvert (which you can't enter exactly in nconvert, as it uses integers and not floats). That constant is:

0.285714285714286

e.g. if you use the HSL filter in Photoshop with a hue shift value of -164, multiply that by the above constant for an equivalent nconvert hue shift value of -46.85 (round that to 47).

*/

; TO DO? Alternately/also transform images with LChuv color space conversion? Produces hue shifts that maintain color intensity more in line with human color perception. On the other hand, hls keeps color intensity with pure (crude) color shift. Both can be favorable, depending. But I think, probably, that with the desaturation variants this script produces as-is, you get variants that may be equivalent to what LCHuv conversion accomplishes.
; Template command, where the three values to modulate are (respectively) brightness, saturation, and hue; 100 = no change, and changes range from 0 to 200:
; imagemagick_convert -define modulate:colorspace=LCHuv -modulate 100,100,25 C:\imageFolder\inputImage.png C:\imageFolder\variants\result.png
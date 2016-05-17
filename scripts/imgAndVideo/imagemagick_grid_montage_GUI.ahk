; imagemagick_grid_montage_GUI found at and adapted from:  http://www.autohotkey.com/board/topic/39534-imagemagick-montage-interface-create-image-tile-sets/
; 06/05/2015 07:41:45 PM -RAH
 ;
 ; WARNING: As good practice, only ever operate on copies of your images with this script (if something goes wrong, you have your originals still).
 ; A basic graphical interface for ImageMagick's montage tool.
 ; Montage turns a set of images into 1 big tiled image, or animated images into one big image (depending on limits in either case).
 ; You could also use this as an image converter.
 ; This is just a very tiny bit of what the actual command-line app can do, but this is the most important stuff in montage. In my opinion.
 
 ; USAGE: Install AutoHotkey, and double-click this script. Follow the prompts/dialogs. NOTE: ImageMagick's montage.exe must be in your %PATH% for this to work.

 ; TIPS/TRICKS:
 ; Leave width or height, or both, at 0 to make a perfect fit on 1 image, accordingly.
 ; Use wild cards in the Names box to search multple extensions.
 ; Click the blue text at the top to go to the ImageMagick website.
 ; It doesn't matter if you type or don't type the leading period in the FileType field.
 ; Allow a while for the image to complete. It may take a while depending on: your PC, how many images, overall image size, file type, image sizes.
 ; The number to the left of the Names box is the number of lines use (images). There is a blank line at bottom by default. That line desnt effect anything. You may leave or delete.
 
;_-Created by: tidbit
;_-Enjoy~~!!
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force


allowed=BMP,GIF,ICO,JPG,JPEG,PNG,SVG,TGA,TIFF
; bgColor=444444	; nuetral gray
bgColor=FFFFFF
help=
(
-> The Wild Card  character ( * ) is supported in the "File type" field.
-> You may use Wildcards in the Names box as well.
-> Please only insert 1 File type (image filetype) in the "File type" field.
-> Enclose file names in quotes (" ") if they have a space in them.
-> bmp, gif, ico, jpg, jpeg, png, svg, tga, tiff. Are all supported.
)

;_-=============-_;
;_-====OTHER====-_;
;_-=============-_;
Gui, font, underline s10
Gui, Add, Text, x6 y4 w350 h28 0x400000 +Center 0x200 Cblue gurl , ImageMagick montage Interface
Gui, font, normal s8

Gui, Add, Text, x6 y38 w40 h20 , Look in:
Gui, Add, Edit, x46 y38 w260 h20 vseldir , %seldir% 		; If the variable seldir has not been initialized, that will be empty.
Gui, Add, Button, x306 y38 w50 h20 gbrowse , Browse

;_-====================-_;
;_-====Width/Height====-_;
;_-====================-_;
Gui, Add, GroupBox, x6 y68 w180 h70 , Width/Height
Gui, Add, Text, x16 y88 w90 h20 , Number of X tiles:
Gui, Add, Edit, x106 y88 w70 h20 +number
Gui, Add, UpDown, x106 y88 w70 h20 0x80 vxt, 3
Gui, Add, Text, x16 y108 w90 h20 , Number of Y tiles:
Gui, Add, Edit, x106 y108 w70 h20 +number
Gui, Add, UpDown, x106 y88 w70 h20 0x80 vyt , 0


;_-===========================-_;
;_-====Tile Offset Spacing====-_;
;_-===========================-_;
Gui, Add, GroupBox, x6 y138 w180 h70 , Tile Offset Spacing
Gui, Add, Text, x16 y158 w90 h20 , Horizontal:
Gui, Add, Edit, x106 y158 w70 h20 +number
Gui, Add, UpDown, x106 y88 w70 h20  Range-1000-1000 0x80 vtsx, 24
Gui, Add, Text, x16 y178 w90 h20 , Vertical:
Gui, Add, Edit, x106 y178 w70 h20 +number
Gui, Add, UpDown, x106 y88 w70 h20 Range-1000-1000 0x80 vtsy, 24

;_-========-_;
;_-==MISC===_;
;_-========-_;
Gui, Add, GroupBox, x186 y68 w170 h140 , Misc
Gui, Add, Button, x196 y88 w100 h20 gcolor , BackGround Color
Gui, Add, Progress, c%bgcolor% x296 y88 w50 h20 vprevcol , 100

Gui, Add, Button, x196 y178 w150 h20 gsave, Save

;_-===========-_;
;_-==FILTERS===_;
;_-===========-_;
Gui, Add, GroupBox, x6 y208 w350 h260 , Filters
Gui, Add, Radio, x16 y228 w330 h20 gfilter vfilter, Manually list Names with the Extensions (1 name per line.).
Gui, Add, Radio, x16 y248 w330 h20  gfilter +Checked, Search all Names and go by Extension.

Gui, Add, Text, x16 y278 w40 h20 , Names:
Gui, Add, Text, x16 y308 w40 h20 vnum, 
Gui, Add, Edit, x56 y278 w290 h80 +HScroll +Disabled vnames gcount,
Gui, Add, Text, x16 y368 w50 h20 , File type:
Gui, Add, Edit, x66 y368 w90 h20 vfiletype,`*
Gui, Add, Text, c9026AF x16 y393 w330 ,%help%

Gui, Show, x131 y91  w362, IMMI`, Created by`: tidbit

; A global variable:
;seldir =

;Check if a parameter was passed to this script (ideally, a correct folder name, e.g. as provided by dragging and dropping a folder on to this script), use it immediately to do this scripts' intended work with the loaded defaults, even to prompting for a save file name.
param1 = %1%
if (param1 != "")
{
; short DOS path string to long conversion, re: http://www.autohotkey.com/board/topic/61457-convert-short-path-to-long-path/
Loop, %param1%, 1		; Dunno why that 1 is necessary? Makes it work . . .
seldir = %A_LoopFileLongPath%
GuiControl, , seldir, %seldir%		; re the browse subroutine.
gosub, getFilenames
		;MsgBox, vale of seldir is:`n`n%seldir%
imgs=`*.`*
save = %seldir%\__all-images-tiled.png		; The path and filename to write the results of the image render to.
		;MsgBox, vale of save is:`n`n%save%
gosub, executeRender
}


Return

;_-========-_;
;_-==SAVE===_;
;_-========-_;
save:
Gui, submit, nohide

 If RegExMatch(seldir, "^\s*$") ;Thanks Titan.
    {
        MsgBox, Please Select a Folder.
        Return
    }
    
FileSelectFile, save , S18,%A_Desktop%, Where would you like to save`?, Images (*.bmp; *.gif; *.ico; *.jpg; *.jpeg; *.png; *.svg; *.tga; *.tiff) All (*.*)

 If RegExMatch(save, "^\s*$") ;Thanks Titan.
        Return
    
        IfInString, save, %a_Space%
            save=`"%save%`"
        Else
            save=%save%
            

 ifinstring, filetype, .
StringReplace, filetype, filetype, .,, ALL

names := RegExReplace(names, "\n", " ")

; Moved some code here to (new for my modification of this script) subroutine executeRender, because tsx and txy not filtered for + characters if the seldir value is set from a parameter (instead of the save dialog). I know that was perfect Greek. Too bad.
gosub, executeRender
return


;_-=================-_;
;_-==RENDER IMAGE===_;
;_-=================-_;
; Render a montage image, using imagemagick's montoge executable, according to user specs from the save dialog or a parameter passed to the script (auto-naming the rendered file after the name of a folder that was dragged and dropped on to this script).
executeRender:
;command = montage.exe -background #%bgcolor% -tile %xt%x%yt% -geometry TSX:%tsx% TSY:%tsy% IMG:%imgs% SAVE:%save%, %seldir%

; Moved the following indented code here from where it had originally been in the save subroutine (see comments in that subroutine).
		if filter=1
		imgs=%names%
		else
		imgs=*.%filetype%

		if tsx>=0
		tsx=+%tsx%
		else
		tsx=%tsx%

		if tsy>=0
		tsy=+%tsy%
		else
		tsy=%tsy%
Run, montage.exe -background #%bgcolor% -tile %xt%x%yt% -geometry %tsx%%tsy% %imgs% %save%, %seldir%
return


;_-==========-_;
;_-==BROWSE===_;
;_-==========-_;
browse:
    FileSelectFolder, seldir, %A_DESKTOP%, 3, Select a folder to search for images.
    If seldir =
        Return		; This is if the file browser dialog's "Cancel" button is pressed.
    Else			; This is if " Ok button is pressed.
        GuiControl, , seldir, %seldir%
	gosub, getFilenames
Return

getFilenames:
    GuiControl, , names,
    Loop, %seldir%\*.*
    {
        Gui, Submit, NoHide
        IfInString, A_LoopFileName, %a_Space%
            j=`"%A_LoopFileName%`"
        Else
            j=%A_LoopFileName%
            
        If A_LoopFileExt Contains %allowed%
            GuiControl, , names,%names% %j%`r`n
    }
    gosub, count
Return

;_-===========-_;
;_-==FILTERS===_;
;_-===========-_;
filter:
    Gui, Submit, NoHide
    If filter=1
    {
        GuiControl, Enable, names
        GuiControl, Disable, filetype
    }
    If filter=2
    {
        GuiControl, Disable, names
        GuiControl, Enable, filetype
    }
Return

;_-================-_;
;_-==COLOR SELECT===_;
;_-================-_;
color:
    CmnDlg_Color( bgColor := 0x444444 )
    If bgColor=false
        Return
    StringReplace, bgColor, bgColor, 0x,
    GuiControl, +c%bgColor%, prevcol
Return

count:
Gui, submit, nohide
Loop, parse, names, `n
    count:=A_Index
GuiControl, ,num, %count%
return

url:
run, http://www.imagemagick.org/script/index.php
return 

GuiClose:
    ExitApp
Return

;----------------------------------------------------------------------------------------------
; Thanks majkinetor for this function
;
;
; Parameters:
;				pColor	- Initial color and output in RGB format,
;				hGui	- Optional handle to parents HWND
;
; Returns:
;				False if user canceled the dialog or if error occurred
;
;
CmnDlg_Color(ByRef pColor, hGui=0){
        ;covert from rgb
        clr := ((pColor & 0xFF) << 16) + (pColor & 0xFF00) + ((pColor >> 16) & 0xFF)

        VarSetCapacity(sChooseColor, 0x24, 0)
        VarSetCapacity(aChooseColor, 64, 0)

        NumPut(0x24,		 sChooseColor, 0)      ; DWORD lStructSize
        NumPut(hGui,		 sChooseColor, 4)      ; HWND hwndOwner (makes dialog "modal").
        NumPut(clr,			 sChooseColor, 12)     ; clr.rgbResult
        NumPut(&aChooseColor,sChooseColor, 16)     ; ColorREF *lpCustColors
        NumPut(0x00000103,	 sChooseColor, 20)     ; Flag: CC_ANYColor || CC_RGBINIT

        nRC := DllCall("comdlg32\ChooseColorA", str, sChooseColor)  ; Display the dialog.
        If (Errorlevel <> 0) || (nRC = 0)
			MsgBox, No clickie teh color! :(
            Return  false


        clr := NumGet(sChooseColor, 12)

        oldFormat := A_FormatInteger
        SetFormat, Integer, hex  ; Show RGB Color extracted below in hex format.

        ;convert to rgb
        pColor := (clr & 0xff00) + ((clr & 0xff0000) >> 16) + ((clr & 0xff) << 16)
        StringTrimLeft, pColor, pColor, 2
        Loop, % 6-StrLen(pColor)
            pColor=0%pColor%
        pColor=0x%pColor%
        SetFormat, Integer, %oldFormat%

     Return true
    }
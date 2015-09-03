ECHO OFF
REM THIS WINDOWS CONSOLE BATCH assists in transforming a source text into a c/c++ string. It converts "unescaped" characters into escape sequences, surrounds the string on each line of a text with double-quotes, broken into a legible multi-line "string" << "string" operator format. It does not do this for the start of the text or end--you must do those manually.

REM TO USE THIS BATCH, 1) Copy this batch file to the same directory as sfk.exe (Swiss File Army Knife--a freely available tool), and rename it with the .bat extension. 2) Create or open a plain-text file in the same directory, named white_space_fixup_scratchpad.txt, and copy and paste into that file (replacing all contents in it) from any source you may want to "fix up" -- e.g. from a .txt, or .cpp file--anything in plain-text format. 3) Execute this batch file. It will alter the contents of said text file per preferences. 4) Copy/paste the fixed-up text to wherever else you want to use it. 4B) NOTE: You may want to first backup whatever source you're fixing up, in case this tool turns out undesireable results.

REM The mentioned (brilliant!) Swiss File Army Knife (sfk.exe) tool may be freely obtained from: http://sourceforge.net/projects/swissfileknife -- note that it is multi-platform, so this batch might easily be adapted for e.g. GNU/Linux or Mac.

IF [%1] NEQ [] SET FILENAME=%1%
IF [%1]==[] SET FILENAME=scratchpad.txt

ECHO Will attempt to operate on FILENAME = %FILENAME% . . .

IF NOT EXIST %FILENAME% (
ECHO FILENAME %FILENAME% was not found.
EXIT /B
)

REM Re: http://en.cppreference.com/w/cpp/language/escape
REM Check it out. I have to use escape sequences for sfk.exe in this batch--some for sfk.exe, and some for the windows consoel--to convert characters to a different escape sequence encoding. Meta!

REM TIMEOUT /T 1

REM GUESS WHAT?! If we don't escape all the backslashes first, it will escape all the escape characters that were escaped before the backslash. Error! Avoid!
REM backslash 	byte 0x5c		\	:
sfk.exe rep %FILENAME% -yes				/\/\\/

REM single quote 	byte 0x27	'	:
sfk.exe rep %FILENAME% -yes				/'/\'/

REM double quote 	byte 0x22	"	:
sfk.exe rep %FILENAME% -yes				/\"/\\\"/
REM question mark 	byte 0x3f	?	:
sfk.exe rep %FILENAME% -yes				/?/\?/
REM horizontal tab 	byte 0x09	\t	:
sfk.exe rep %FILENAME% -yes -spat		/\t/\\t/
REM Break lines (hard returns) apart into the format:
REM 	<< "string\n"
REM 	<< "string\n"
sfk.exe rep %FILENAME% -spat -yes "/\r/\\n\"\r\t^<^< \"/"

REM TODO: See also sfk filter -wrap; to split a line of text into the console width!
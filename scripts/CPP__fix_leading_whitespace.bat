ECHO OFF
REM Featuring: an entire page-and-a-half of proper documentation before even a lick of code! :)

REM THIS WINDOWS CONSOLE BATCH replaces quadruple/double-space indents (in a plain-text file) with tabs, to the nearest four-space tab. It only does this for spaces after a newline, though it may be modified to operate on all quadruple/double-spaces in a text file. It may also reverse this process; for that, see the FURTHER DETAILS section after all of the batch code lines.

REM THE POINT is to quickly make text more useful which is e.g. sourced from web documents, or programmers who have different code white-space preferences than I do :)

REM TO USE THIS BATCH, 1) Copy this batch file to the same directory as sfk.exe (Swiss File Army Knife--a freely available tool), and rename it with the .bat extension. 2) Create or open a plain-text file in the same directory, named white_space_fixup_scratchpad.txt, and copy and paste into that file (replacing all contents in it) from any source you may want to "fix up" -- e.g. from a .txt, or .cpp file--anything in plain-text format. 3) Execute this batch file. It will alter the contents of said text file per preferences. 4) Copy/paste the fixed-up text to wherever else you want to use it. 4B) NOTE: You may want to first backup whatever source you're fixing up, in case this tool turns out undesireable results.

REM The mentioned (brilliant!) Swiss File Army Knife (sfk.exe) tool may be freely obtained from: http://sourceforge.net/projects/swissfileknife -- note that it is multi-platform, so this batch might easily be adapted for e.g. GNU/Linux or Mac.

REM BATCH CODE
REM Loop count control variable.
SET /A ITER=0

IF [%1] NEQ [] SET FILENAME=%1%
IF [%1]==[] SET FILENAME=scratchpad.txt

ECHO Will attempt to operate on FILENAME = %FILENAME% . . .

IF NOT EXIST %FILENAME% (
ECHO FILENAME %FILENAME% was not found.
EXIT /B
)


REM Pre-parsing fixups

REM Replace all hard returns \r with newlines \n, else this batch will accomplish nothing, in some cases--and also for code editors/compilers:
sfk.exe rep %FILENAME% -spat "/\r/\n/" -yes

REM Trailing whitespace fixup--doesn't yet catch stupid tabs . . .
sfk.exe rep %FILENAME% -spat "/  \n/\n/" -yes
sfk.exe rep %FILENAME% -spat "/ \n/\n/" -yes
REM Curly quotes:
REM Binary for open-quote mark (“) -- in what encoding? -- and is this cross-platform? : E2809C
REM For close-quote mark (”) : E2809D
REM For straight double-quote mark ("): 22
sfk.exe rep %FILENAME% -binary -spat "/E2809C/22/" -yes
sfk.exe rep %FILENAME% -binary -spat "/E2809D/22/" -yes
REM replace with em-dashes (–) with --: binary is E28093 (dash is 2D);
sfk.exe rep %FILENAME% -binary -spat "/E28093/2D2D/" -yes
REM replace ` character with '. Maybe you want that? Too bad--if so, this will break it }:]
sfk.exe rep %FILENAME% -binary -spat "/60/27/" -yes

IF [%2] NEQ [] (
GOTO FIXTABS
) ELSE (
GOTO FIXSPACES
)


:FIXSPACES
ECHO IN LOOP . . .
REM For cases where code after a newline is indented with one or more spaces (in the range of 9 to 26 spaces)
sfk.exe rep %FILENAME% -spat "/\n                          /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n                         /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n                        /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n                       /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n                      /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n                     /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n                    /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n                   /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n                  /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n                 /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n                /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n               /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n              /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n             /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n            /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n           /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n          /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n         /\n/" -yes
sfk.exe rep %FILENAME% -spat "/\n /\n\t/" -yes
REM For cases after newlines where spaces are used instead of tabs; the next four lines of code:
REM Changes four spaces after newline to two tabs:
sfk.exe rep %FILENAME% -spat "/\n\t    /\n\t\t/" -yes
REM Changes two spaces after newline to one tab:
sfk.exe rep %FILENAME% -spat "/\n\t  /\n\t/" -yes
REM Aligns any straggled space before a tab (and after a newline) to the line start:
sfk.exe rep %FILENAME% -spat "/\n \t/\n/" -yes
REM Aligns any straggled space after a tab (which comes after a newline) to the next tab:
sfk.exe rep %FILENAME% -spat "/\n\t /\n\t/" -yes

SET /A ITER=ITER+1

IF %ITER% LSS 6 GOTO FIXSPACES
ECHO Finished leading space to tabs manipulation of %FILENAME%.
EXIT /B


:FIXTABS
REM In descending order, change newlines followed by so many tabs to so many spaces; up to thirteen tabs (blegh!). But if your code has more than about six indents for flow control, you need different code.
REM But first, replace all spaces that are between tabs (up to four spaces) to the nearest tab.
sfk.exe rep %FILENAME% -spat "/\t    \t/\t\t/" -yes
sfk.exe rep %FILENAME% -spat "/\t   \t/\t\t/" -yes
sfk.exe rep %FILENAME% -spat "/\t  \t/\t/" -yes

REM Two possibilities here; the first preferred; therefore the second is commented out by default. Switch these if you prefer.
sfk.exe rep %FILENAME% -spat "/\t \t/\t /" -yes
REM sfk.exe rep %FILENAME% -spat "/\t \t/\t/" -yes

sfk.exe rep %FILENAME% -spat "/\n\t\t\t\t\t\t\t\t\t\t\t\t\t/\n             /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t\t\t\t\t\t\t\t\t\t\t\t/\n            /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t\t\t\t\t\t\t\t\t\t\t/\n           /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t\t\t\t\t\t\t\t\t\t/\n          /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t\t\t\t\t\t\t\t\t/\n         /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t\t\t\t\t\t\t\t/\n        /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t\t\t\t\t\t\t/\n       /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t\t\t\t\t\t/\n      /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t\t\t\t\t/\n     /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t\t\t\t/\n    /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t\t\t/\n   /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t\t/\n  /" -yes
sfk.exe rep %FILENAME% -spat "/\n\t/\n /" -yes

SET /A ITER=ITER+1
IF %ITER% LSS 6 GOTO FIXTABS

ECHO Finished leading tabs to spaces manipulation of %FILENAME%.


REM FURTHER DETAILS: ADDITIONAL USAGE, LIMITATIONS, POSSIBLE CHANGES
REM You may call this batch with one paramater, being a filename, and it will operate on said filename. Moreover, if you call it with a second parameter, it will reverse the process and align leading tabs to spaces (as it deletes those tabs). NOTE, however, that if you use a second parameter, you must use the first (and explicitly tell the batch which file to operate on). No, I won't fix that.

REM AS A GLOBAL UTILITY, if you set this batch in your %PATH%, you may then call it from any other directory (from the console etc.), which means you can indescriminately destroy or repair the formatting (or even the binary contents of?) arbitrary files (depending). If so, BE CAREFUL. Also, I haven't tested that--I only assume it would be so.

REM Known limitations: It doesn't operate on the first line of a text file. Also, to partly mitigate incorrect retranslation (if e.g. you run spaces-to-tabs and then try translating back, by running tabs-to-spaces), the tabs-to-spaces routine may sometimes place one space after a tab. If you don't want that, find the portion of that routine where one vs. another line is commented, and reverse those comments. No, I won't fix these problems. Also, it's unavoidable that if you align to the nearest four-tab as you delete spaces, and then save the file, you lose information that you can't get back. Obviously, it's information I don't care for :)

REM It's a simple thing to modify this batch to replace *all* quadruple/double-spaces with tabs (instead of only changing extra spaces after newlines), as follows; but I warn you: that may produce undesireable results. For example, it may introduce tabs into string declarations, which e.g. may be ignored in C/C++ iostreams code. To make this batch so indiscriminate about the replacement of multiple spaces, modify all the search/replace patterns which start with a hard return (\n -- also, only in the FIXSPACES routine) to *not* start with a newline, e.g.
REM 	"/\n /\n/"
REM -- would change to:
REM		"/ /\n/"

REM Second-to-lastly, because some texts are seriously space-wonky, it's common to need to do the search-replace several times on a source. This batch therefore runs through whichever whitespace-fixup loop you choose six times.
REM revamped to use simpler script. 08/29/2014 12:49:24 PM -RAH
REM usage: first open a console using fontforge-console.bat (which comes with the fontforge win distribution), then invoke this batch with a parameter: the name of a .tff font to convert to .otf (Open Type Font) and .woff (web font).

FOR /f "tokens=* delims= " %%F IN ('DIR *.ttf /B') DO (
fontforge.exe  -script convert.pe %%F
)
REM DESCRIPTION
REM Escapes troublesome characters in an arbitrary text file (parameter %1%),
REM in-place, so that the text can be used in a batch script without errors.
REM WARNING: overwites file %1% without warning. Back it up if you need
REM its contents unmodified or in case this batch doesn't do what you want.

REM USAGE
REM Run this batch with one parameter, being the file you want to
REM have escape sequences added to in-place; e.g.:
REM escapeTextFileString.bat wonderousEvolutionOfPants.txt

REM DEPENDENCIES
REM A 'nixy environment (e.g. Cygwin or MSYS2) on Windows.

REM Developer comments:
REM How freaky meta is this? I'm escaping characters to replace them with
REM escape characters so that I can substitute a path with the collective
REM of them.
REM REFERENCE: http://www.robvanderwoude.com/escapechars.php
REM Search-replace expressions that don't apply to DOS filenames (see
REM reference) are commented out.
REM Everything commented out with the label ~~ is not allowed in DOS
REM file names (and therefore of no concern here), specifically these
REM characters: \/:*?"<>| -- HOWEVER, note that the backslash \ is of
REM concern in path names, so it is included! And there just better not
REM be any use of ^ in my use case, or it'll screw this up. Commenting
REM that character out. 01/26/2015 07:10:23 PM -RAH

COPY /Y %1% temp_sed_working_file.txt
SET SEARCH_FILE_NAME=temp_sed_working_file.txt

SET SEARCH_FILE_NAME=temp_sed_working_file.txt

sed -i s/\\/\\\\/g %SEARCH_FILE_NAME%
sed -i s/\./\\./g %SEARCH_FILE_NAME%
sed -i s/^;/^^^;/g %SEARCH_FILE_NAME%
sed -i s/^,/^^^,/g %SEARCH_FILE_NAME%
sed -i s/^=/^^^=/g %SEARCH_FILE_NAME%
sed -i s/^(/^^^(/g %SEARCH_FILE_NAME%
sed -i s/^)/^^^)/g %SEARCH_FILE_NAME%
sed -i s/\[/\\[/g %SEARCH_FILE_NAME%
sed -i s/\]/\\]/g %SEARCH_FILE_NAME%
sed -i s/%%/%%%%/g %SEARCH_FILE_NAME%
sed -i s/^^!/^^^^!)/g %SEARCH_FILE_NAME%
sed -i s/^&/^^^&/g %SEARCH_FILE_NAME%
sed -i s/^'/^^^'/g %SEARCH_FILE_NAME%
sed -i s/^`/^^^`/g %SEARCH_FILE_NAME%
REM EVIL sed -i s/^^/^^^^/g %SEARCH_FILE_NAME%
REM Required only inside the search pattern of the DOS FIND command: sed -i s/""/"""")/g %SEARCH_FILE_NAME%
REM And covered already; only relevant inside FINDSTR calls: sed -i s/\"/\\"/g %SEARCH_FILE_NAME%
REM ~~ sed -i s/^</^^^</g %SEARCH_FILE_NAME%
REM ~~ sed -i s/^>/^^^>/g %SEARCH_FILE_NAME%
REM ~~ sed -i s/^|/^^^|/g %SEARCH_FILE_NAME%
REM ~~ sed -i s/\*/\\*/g %SEARCH_FILE_NAME%
REM ~~ sed -i s/\?/\\?/g %SEARCH_FILE_NAME%

DEL "%1%"
COPY /Y temp_sed_working_file.txt "%1%"
DEL temp_sed_working_file.txt
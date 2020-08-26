:: DESCRIPTION
:: Escapes troublesome characters in an arbitrary text file (parameter %1%), in-place, so that the text can be used in a batch script without errors.

:: USAGE
:: Run this batch with one parameter, which is the file you want to
:: have escape sequences added to in-place; e.g.:
::    escapeTextFileString.bat wonderousEvolutionOfPants.txt
:: WARNING
:: Overwrites file %1% without warning. Backing it up before running this
:: batch is advised.

:: DEPENDENCIES
:: A 'Nixy environment (e.g. Cygwin or MSYS2) on Windows.


:: CODE
:: TO DO
:: Get it working? It ain't, apparently.
:: - rework this to and rename this to a .sh script? I mean it's using a GNU core util . . .
:: Developer comments:
:: How freaky meta is this? I'm escaping characters to replace them with
:: escape characters so that I can substitute a path with the collective
:: of them.
:: REFERENCE: http://www.robvanderwoude.com/escapechars.php
:: Search-replace expressions that don't apply to DOS filenames (see
:: reference) are commented out.
:: Everything commented out with the label ~~ is not allowed in DOS
:: file names (and therefore of no concern here), specifically these
:: characters: \/:*?"<>| -- HOWEVER, note that the backslash \ is of
:: concern in path names, so it is included! And there just better not
:: be any use of ^ in my use case, or it'll screw this up. Commenting
:: that character out. 01/26/2015 07:10:23 PM -RAH

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
:: EVIL sed -i s/^^/^^^^/g %SEARCH_FILE_NAME%
:: Required only inside the search pattern of the DOS FIND command: sed -i s/""/"""")/g %SEARCH_FILE_NAME%
:: And covered already; only relevant inside FINDSTR calls: sed -i s/\"/\\"/g %SEARCH_FILE_NAME%
:: ~~ sed -i s/^</^^^</g %SEARCH_FILE_NAME%
:: ~~ sed -i s/^>/^^^>/g %SEARCH_FILE_NAME%
:: ~~ sed -i s/^|/^^^|/g %SEARCH_FILE_NAME%
:: ~~ sed -i s/\*/\\*/g %SEARCH_FILE_NAME%
:: ~~ sed -i s/\?/\\?/g %SEARCH_FILE_NAME%

DEL "%1%"
COPY /Y temp_sed_working_file.txt "%1%"
DEL temp_sed_working_file.txt
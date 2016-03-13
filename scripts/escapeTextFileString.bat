REM How freaky meta is this? I'm escaping characters to replace them with escape characters so that I can substitute a path with the collective of them.

REM General purpose to replace characters in any text file which DOS will mangle without escape sequences.

REM REFERENCE: http://www.robvanderwoude.com/escapechars.php
REM Search-replace expressions that don't apply to DOS filenames (see reference) are commented out.

REM Everything commented out with the label ~~ is not allowed in DOS file names (and therefore of no concern here), specifically these characters: \/:*?"<>| -- HOWEVER, note that the backslash \ is of concern in path names, so it is included! And there just better not be any use of ^ in my use case, or it'll screw this up. Commenting that character out. 01/26/2015 07:10:23 PM -RAH

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
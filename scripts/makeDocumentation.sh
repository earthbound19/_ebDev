# DESCRIPTION
# Collates documentation comments from all code/script files in the current directory and subdirectories into one file: `<repoName>_DOCUMENTATION.md` (assumes it is part of a git repository and names the first part of the file after the repository; if that isn't the case it may just end up named `_DOCUMENTATION.md`), for easier documentation reference. Uses a subset of Mardkwon to allow source code comments loosely styled after Markdown to be converted for final rendered documentation. See USAGE.

# DEPENDENCIES
# - LibreOffice installed with soffice.exe in your PATH
# - generate-md (markdown-styles) from npm https://github.com/mixu/markdown-styles/blob/master/bin/generate-md (install with `npm install -g markdown-styles`)
# git (a requirement I don't like and would like to change), various GNU tools that come with most Bash environments (e.g. MSYS2), wget

# USAGE
# In the source code of every script in this repository (or any other repository that you want to use this script for), follow this documentation convention:
# - REQUIREMENT. Write a documentationHeader.md file which introduces and generally describes the documentation for scripts in the repository. Also a documentationFooter.md document, which has whatever information you want to follow the general body document (which is made from documentation comments in so many scripts) with. NOTE: this script inserts a newline and a "Generated at <date and time> print on the 2nd line of the header (so that the format is <header line>\n<Generated at <date and time>. It expects the result of this to be a header, a blank line, an inserted document generation time, another blank line, and the remainder of the header.
# - REQUIREMENT. Everything before a code begin comment marker is documentation that will be collated into <repoName>_DOCUMENTATION.md (adapted to markdown format) when you run this script.
# - REQUIREMENT. The code begin comment marker is simply the word 'CODE' (without the quote marks, and with no punctuation and no other words or anything else other than the comment marker, thought whitespace is allowed before or after the comment marker and/or the word 'CODE'). Supported comment markers are: #, //, %, ::, REM, ;, ;;, and possibly others I may add (check the awk command in this script). An example of a code begin marker for a powershell file would be:
#        % CODE
# - REQUIREMENT. Document important general information that is suitable for subheaders by writing only a comment marker, and any whitespace before and after, and an all-caps word, and _no other punctuation or character types._ Examples of such headers are '# DESCRIPTION', '// USAGE', ';; NOTES', etc. (without the quote marks for any of those examples.) These will be converted to Markdown 4th-level headers.
# - REQUIREMENT. If the source code is an executable script (such as a python, bash or Perl script) which accepts CLI parameters, explain and give examples of those parameters. Indent example commands (such as to run the script) four spaces after a source code comment marker. Eight spaces if they follow a Markdown list item on the previous line (if the command example is with list items). Re: https://daringfireball.net/projects/markdown/syntax
# - REQUIREMENT. Any documentation of commands that comes immediately after headers and is intended to be presented as technical information (such as example commands) must first have a header, then at least one line of text immediately after that, then the technical information on the next line. This is a limitation of how I parse documentation, but it's also a preference (for example, to introduce the technical information, however briefly, on the line before it).
# - RECOMMENDATION. If documentation includes double dashes `--` as syntax, put the code containing that syntax on a separate line preceded by quadruple spaces, or else Pandoc will convert it to an em-dash for display, which is not correct. But you may also surround the syntax that is part of the `--` with backticks for inline preformatted (technical information/code) Markdown.
# - RECOMMENDATION. Where it is more useful (including for convenience sake), put markdown backticks around words or phrases inline right in text, even if it leads to syntactical confusion in readers of the comment source code (to wonder why those are there).
# - All documentation lines will have two spaces appended to the end of the line by this script, to force newlines in Markdown (to preserve intended newline breaks).
# - Even if a script requires no parameters to run, I prefer to give an example command to run the script, under a USAGE header, like this:
#    scriptName.sh parameterOne parameterTwo
# WITH ALL THOSE documentation requirements in place for every source code etc. file in a given repository, and to use this script to make good of so much documentation, and from a directory containing those code etc. files (and this script will also include files in subdirectories), run this script without any parameters:
#    makeDocumentation.sh
# (For the `_ebDev` repo, I run it from within the /scripts folder.)
# After parsing and collation, results will appear in `<repoName>_Documentation.md`.
# NOTES
# - For the curiosity of listing files newest first according to when they were first committed to git, before you run makeDocumentation.sh, first run this script, from the repository root:
#        setFileTimestampsToEarliestGitCommit.sh
# - The resultant `<repoName>_Documentation.md` file is expected to be large and frequently changing, so good practice is to not store it in a git repository; to exclude it via `.gitignore`.


# CODE
# TO DO
# - remove dependency of git/repo and define folder/project/file name of output .pdf a better way?
# - remove these from parsed files (allows print_halp function: )
#    function print_halp {
#    echo "
#    "
#    }
# DEVELOPER NOTES
# - Always ensure this list of supported comment markers is in both the AWK_CODE_MARKER_SEARCH_COMMAND (see commment with that string) and SED_COMMENT_STRIP_COMMAND (see also comment with that string): # // """ % :: REM ; ;;
# - To manually clean up my preference of not having a colon after all caps pseudo (not markdown) headers in code comments, I found them via npp search all files, with "Match case" ticked and "Regular expression" selected, and this find string: ^[#/%:RrEeMm ]*[[:UPPER:]]{1,}:$
# - I was not able to get semicolons to work in that expression.
# - list of all relevant extensions for NPP search-replace: *.py *.sh *.pl *.ahk *.ps *.ps1 *.cmd *.bat *.reg *.md


if [ ! -e documentationHeader.md ] || [ ! -e documentationFooter.md ]; then printf "\n~\nPROBLEM! File documentationHeader.md and/or documentationFooter.md not found. Ensure it exists and is in the same directory you run this script from. Will exit script.\n~\n"; exit 1; fi

# ACKNOWLEDGED INSANITY; counts on path not to end with / or \:
repoName=$(git rev-parse --show-toplevel | sed 's/\(.*[\/\\]\)\([^\/\\]*\)/\2/g')
MDtargetDocumentationName="$repoName"_Documentation.md
printf "\nWill create document $MDtargetDocumentationName.\n"

# start document with header; most of the rest of the script appends to it:
cat documentationHeader.md > $MDtargetDocumentationName
printf "\n\n" >> $MDtargetDocumentationName
# Set a value we treat like a boolean to terminate script later if necessary:
terminateScriptBecauseDocumentationStyleErrorFound="False"

currentDir=$(pwd)
currentDirBasename=$(basename $currentDir)
# Creates an array of the relative path to so many different files of so many types, from the print of another script:
sourceCodeFilesArray=($(printFilesTypes.sh NEWEST_FIRST pde py sh pl ahk ps ps1 cmd bat reg))
numberOfFoundFiles=${#sourceCodeFilesArray[@]}
# wipe and recreate temp dir for files parsing:
if [ -d tmp_makeDocumentationParsing_tZFc76 ]; then rm -rf tmp_makeDocumentationParsing_tZFc76; fi
mkdir tmp_makeDocumentationParsing_tZFc76
# file numbering counter for temp files and curiosity:
counter=0
for fileNameWithPath in ${sourceCodeFilesArray[@]}
do
	# get file name without path:
	fileNameWithoutPath=$(basename $fileNameWithPath)
	counter=$((counter + 1))
	printf "\nParsing and collating documentation from file $counter of $numberOfFoundFiles: $fileNameWithPath . . . "
	# Write Markdown preformatted text section header; note the \ escaping the backtick \` :
	tmpHeaderFile=tmp_makeDocumentationParsing_tZFc76/file_number_"$counter"__"$fileNameWithoutPath"_title_header.txt
	printf "### $fileNameWithPath\n\n" > $tmpHeaderFile
	# Copy script for parsing to temp file and convert it to encoding/line endings expected by the GNU coreutils I use, because some text file encodings fail in awk otherwise:
	tmpParsingFile=tmp_makeDocumentationParsing_tZFc76/file_number_"$counter"__"$fileNameWithoutPath".txt
	cp $fileNameWithPath $tmpParsingFile
	dos2unix $tmpParsingFile
	# Find line number of CODE comment; this allows comments from many different languages; AWK_CODE_MARKER_SEARCH_COMMAND:
	lineNumber=$(awk -v search="^[[:blank:]]{0,}(#|//|%|::|REM|;|;;){1,}[[:blank:]]{0,}CODE[[:blank:]]{0,}$" '$0~search{print NR; exit}' $tmpParsingFile)
	if [ "$lineNumber" == "" ]
	then
		thisScriptName=$(basename "$0")
		printf "\n\nERROR: could not find CODE begin partition comment in file $fileNameWithPath (which should be a commetn with only the word 'CODE' (without quote marks) on one line, and nothing else), either because it doesn't exist, or the regexp used to find it failed. Examine that file, and if it exists, fix the awk command in this file ($thisScriptName) to find it."
	fi
	# Use that line number minus one to print everything up to it to a temp file:
	lineNumber=$(($lineNumber - 1))
	head -$lineNumber $fileNameWithPath > $tmpParsingFile
	# ==== BEGIN WINDOWS .reg removal of registry editer version declaration we don't want
	fileExt=${fileNameWithPath##*.}
	# In case that file ext. is uppercase, lowercase it:
	fileExt=$(echo "$fileExt" | tr '[:upper:]' '[:lower:]')
	if [ "$fileExt" == "reg" ]; then
		lineNumberOfRegistryEditorSTR=$(awk -v search=".*Windows Registry Editor Version.*" '$0~search{print NR; exit}' $tmpParsingFile)
		# if that match was found, the value of the variable it was assigned to will be non-empty; only use it if it non-empty:
		if [ "$lineNumberOfRegistryEditorSTR" != "" ]
		then
			# sed command to delete specific line re https://www.folkstalk.com/2013/03/sed-remove-lines-file-Unix-examples.html -- and because I cannae figure out how to run that variable as part of command, store the command in a variable with the other parts of the command, then use _that_ variable between "" :
			sedCommand="$lineNumberOfRegistryEditorSTR"d
			sed -i "$sedCommand" $tmpParsingFile
		fi
	fi
	# ==== END WINDOWS .reg removal of registry editer version declaration we don't want
	# ==== BEGIN shabang line strip ====
	# Find line number of any shebang line and delete that line from file if it is found (it is out of place in documentation but otherwise can be needed as first line of script, so I'm not removing it from any scripts in the repository) :
	shebangLineNumber=$(awk -v search='^#!/.*' '$0~search{print NR; exit}' $tmpParsingFile)
	if [ "$shebangLineNumber" != "" ]
	then
		sedCommand="$shebangLineNumber"d
		sed -i "$sedCommand" $tmpParsingFile
	fi
	# ==== END shabang line strip ====
	# Strip comment markers from file, leaving the rest of the text in the comment intact; the word CHULFOR here is a positional parameter which can be anything, and which tells the script to ovewrite the original file:
	commentMarkerStrip.sh $tmpParsingFile CHULFOR
		# ========
		# BEGIN DOCUMENTATION STYLE CHECKS
		# CHECK FOR TO DO lists below CODE (start) comment; automatically open, for editing, any file which has TO DO in the comments above the CODE comment we already filtered for; assumes that the source script file types are associated with a text editor:
		grep -q "[[:blank:]]*TO DO" $tmpParsingFile
		error_level=$(echo $?)
		if [ $error_level -eq 0 ]
		then
			terminateScriptBecauseDocumentationStyleErrorFound="True"
			printf "\nPROBLEM! TO DO comment above CODE comment in $fileNameWithoutPath. Opening that file. Edit it so that the TO DO list is below the CODE comment. When done, press any key to continue:"
			start $fileNameWithPath
			read -rsn1
		fi
		# ENFORCEMENT of minimum four spaces at the start of every line in comments that begin with the script name, so this parser will rework them to Markdown preformatted text. Test grep command that helped develop this: grep -q "^ \{0,1\}foo*" file_number_45__ftun.sh.txt
		grep -q "^ \{0,3\}$fileNameWithoutPath*" $tmpParsingFile
		error_level=$(echo $?)
		if [ $error_level -eq 0 ]
		then
			terminateScriptBecauseDocumentationStyleErrorFound="True"
			printf "\nPROBLEM! File $fileNameWithoutPath has one or more comments with its own file name at the start of a comment and without four spaces before it. Four spaces before the script name are a documentation requirement, to render any command with the script as preformatted (technical/code-styled-information) via adaptation of the comment to Markdown. Open that file, and change it to have at least four spaces (after the code comment marker, and) before the file name. If it is listed on a line after after a Markdown list item ( - ), indent it with eight spaces, not four. After you edit the file, press any key to continue:"
			# This assumes that script files are associated with a text editor; uncomment at your own risk:
			start $fileNameWithPath
			read -rsn1
		fi
		# END DOCUMENTATION STYLE CHECKS
		# ========
	# SANITIZE INPUT: later text processing can be mucked up by these problems unless we fix them up; eliminate any whitespace from the end of lines _and_ (this works out that way) from blank lines:
	sed -i 's/[[:space:]]*$//g' $tmpParsingFile
	# Comment markers now stripped, for all lines that have only one whitespace character (tab or space) and then characters other than whitespace, strip that one whitespace character; leaves alone lines that have two or more whitespace characters at the start of the line:
	sed -i 's/^ \([^ ]\)/\1/g' $tmpParsingFile
		# DEPRECATED: in all comments where there are at least two blank spaces before text, change the line to start with four blank spaces. This will clobber any lines that have varying indents which are guides for humans to separate different logical blocks etc. I'm not fixing that. And I don't know that I ever use such indentation in command examples in comments. Deprecated because it turns out that I do want more than four spaces before preformatted text in at least one setting: when it is immediately after a Markdown list item.
		# DEPRECATED conversion command: sed -i 's/^ \{2,\}\([^ ].*\)/    \1/g' $tmpParsingFile
	# Turn lines that were Markdown-sytle list items (but had the space before the dash ' - ' stripped by a previous sed operation in this loop) back into those:
	sed -i 's/^- \(.*\)/ - \1/g' $tmpParsingFile
	# Turn resulting (from all the editing) "headers" that are nothing but a word in all caps at the start of a line (with optional whitespace between and after words) into Markdown level 4 headers:
	sed -i 's/^\([A-Z ]\{1,\}\)$/#### \1/g' $tmpParsingFile
	# For all result temp parsing docs from all comment blocks that meet these criteria:
	# - More than one space before other characters on the line (intent: markdown preformatted text)
	# - At least one line like this (PREVIOUSLY: at least two: \)\{2,\}/)
	# Do this: pad them to have blank lines above and below. This causes a Markdown parser to render them as preformatted (in every renderer I've seen: monospace font) text.
	# THIS WAS EXTREMELY DIFFICULT TO PULL OFF;
	# re: https://stackoverflow.com/a/1252191/1397555
	# re: https://Unix.stackexchange.com/a/155385/110338
	sed -i -e ':a;N;$!ba;s/\( \{2,\}[^\n]*\n\)\{1,\}/\n&\n/g' $tmpParsingFile
	# Put newlines before and after all groups of lines which are Markdown list items, so that they will be rendered as list items in Markdown (similarly to a previous sed operation) :
	sed -i -e ':a;N;$!ba;s/\( - [^\n]*\n\)\{1,\}/\n&\n/g' $tmpParsingFile
	# Put a blank line before and after all headers (as these extra newlines are because my doc. style sometimes shirks that but some (all?) Markdown renderers require it) (will clean up any resulting excess newlines later) ; NOTE that without the line start and end ^$ codes this led to lines with pound signs in the middle being cut in the middle (that was a not fun thing to debug) :
	sed -i -e 's/\(^#\{1,\}[^\n]*$\)/\n\1\n/g' $tmpParsingFile
	# To force preservation of intended line breaks (where Markdown rendering can muck that up vs. how it is written in comments in my script), append two spaces to the end of every line; may result in some blank lines with extra whitespace that will be cleaned up later; for some time I accidentally was doing this twice, with a variant sed command which I think accomplishes the same: `sed -i 's/\(.*\)/\1  /g' $tmpParsingFile`
	sed -i 's/\(.*\)$/\1  /g' $tmpParsingFile
	# Consolidate temp header and body and append to $MDtargetDocumentationName:
	cat $tmpHeaderFile $tmpParsingFile >> $MDtargetDocumentationName
done
# Don't continue beyond that loop if documentation style errors were found, and notify user to run script again:
if [ "$terminateScriptBecauseDocumentationStyleErrorFound" == "True" ]
then
	printf '\n~\nNOTICE!\n\nBecause documentation style errors were found (though hopefully you fixed them), the script will need to be run again to start parsing over. Exiting. Manually run the script again.\n~\n'
	exit 1
fi

# Dunno whether these extra newlines will be needed (may depend on what that last collated document was); if they are excess steps after this will trim them:
printf "\n\n\n" >> $MDtargetDocumentationName
# Concatenate target document and document footer to temp file, then move temp file over final document:
cat $MDtargetDocumentationName documentationFooter.md > tmp_makeDocumentationParsing_tZFc76/__semiFinalDocumentationFile_tmp_nuaMVF.txt
mv -f tmp_makeDocumentationParsing_tZFc76/__semiFinalDocumentationFile_tmp_nuaMVF.txt $MDtargetDocumentationName

rm -rf tmp_makeDocumentationParsing_tZFc76
# the text processing resulted in things I don't want; fix them up:
# - blank all lines that have only whitespace:
sed -i 's/^[[:blank:]]*$//g' $MDtargetDocumentationName
# - remove trailing spaces added to markdown list items (which otherwise messes up their rendering with extra space) :
sed -i 's/\(^ - .*\)  $/\1/g' $MDtargetDocumentationName
# - reduce all instances of two or more blank lines (which can result from all the above collation/processing, or from bad writing) to one:
sed -i ':a;N;$!ba;s/\n\{3,\}/\n\n/g' $MDtargetDocumentationName
# - only a reading preference for the way I'm using headers here, but: add a blank line (which after all this processing will lead to a double blank line, which is what I want) before all header levels 1-3 (but leave header levels 4 or more alone) :
sed -i 's/\(^#\{1,3\}[^#].*$\)/\n\1/g' $MDtargetDocumentationName
# - that may lead to the first lines of the file being blank, so delete blank starting lines until there are no more; a painful necessity little loop at the end of a long script; and this works but I suspect there's a more efficient logic that could do this:
result='1:'
while [ $result == '1:' ]
do
	result=$(grep -n "^[[:blank:]]\{0,\}$" $MDtargetDocumentationName | head -n 1)
	if [ $result == '1:' ]
	then
		# chomp off first line of file, which is blank:
		tail -n +2 $MDtargetDocumentationName > tmp_makeDocumentation_sh__DCW8Jxyx4.txt
		mv tmp_makeDocumentation_sh__DCW8Jxyx4.txt $MDtargetDocumentationName
	fi
done

# Write document generation date and time just after first header line of file:
sed -i "2 i\\\n_Generated $(date +%Y-%m-%d) $(date +%I:%M:%S) $(date +%p)_" _ebDev_Documentation.md

# Wipe target conversion subfolder if it exists (will be recreated immediately) :
if [ -d _tmp_WPcnYHrGD_documentation_rendering ]
then
	rm -rf _tmp_WPcnYHrGD_documentation_rendering
	echo DELETED folder _tmp_WPcnYHrGD_documentation_rendering . . .
fi
mkdir _tmp_WPcnYHrGD_documentation_rendering

cd _tmp_WPcnYHrGD_documentation_rendering
# Move result doc into this subfolder . . .
cp ../$MDtargetDocumentationName .
# Set render target file name:
odtOutputFileName=${MDtargetDocumentationName%.*}.odt
# Retrieve style template:
if [ ! -e ../style-template.odt ]
then
	wget https://earthbound.io/data/doc/style-template.odt
else
	cp ../style-template.odt ./
fi

# Render it to odt
pandoc -t odt \
-o $odtOutputFileName \
--reference-doc=style-template.odt \
$MDtargetDocumentationName
rm style-template.odt

# Convert odt to pdf and docx:
soffice.exe --convert-to pdf $odtOutputFileName --headless
soffice.exe --convert-to docx $odtOutputFileName --headless
# Convert md to HTML:
generate-md --lagenerate-md --layout jasonm23-dark --input ./$MDtargetDocumentationName --output ./

cd ..

printf "\n~\nDONE. Source markdown document and results converted from it are in the folder _tmp_WPcnYHrGD_documentation_rendering. Copy them out of there to an archival and/or distribution place, and delete the folder.\n"

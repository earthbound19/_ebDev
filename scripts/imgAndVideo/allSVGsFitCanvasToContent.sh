# DESCRIPTION
# Resaves all SVGs in a directory (and optionally subdirectories) so that the view canvas shows everything. Useful for example for adjusting auto-exported glyphs from fonts where the canvas crops out things below the letter baseline. In detail: for every vector file of a given type (default SVG) in the current directory (and optionally all subdirectories), selects all, resizes the canvas to fit the selection, and exports a plain (if possible?) format version of that file over itself.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. File format to work on; all files of this type in the current directory will be worked on.
# - $2 OPTIONAL. Anything, for example the word Psychoudy, which will cause the script to operate on all files of type $1 in all subdirectories also. If omitted, only files of type $1 in the current directory will be operated on. Note that to use this you must specify a value for $1 (you can't omit $1 to use the default).
# For example, to resave all SVG format files in the current directory so the canvas accomodates a view of everything in the file, run this without any parameters:
#    allSVGsFitCanvasToContent.sh
# To work on SVGs in the current directory and all subdirectories also, specify svg for the first parameter and anything for the second parameter:
#    allSVGsFitCanvasToContent.sh svg STAR
# NOTE that I actually don't know what this can operate on besides svg files and have only coded it to accomodate that known possibility.


# CODE
# set input file type from $1 else default to svg
if [ "$1" ]; then inputFileType=$1; else inputFileType=svg; echo "\nNo parameter \$1 (input file type) passed to script. Defaulting to svg."; fi

# set the find commands' maxdepth switch to only one level deep if no parameter or NULL is passed for $2, and default to nothing (which searches all subdirectories) if a parameter other than NULL is passed for $2:
if [ ! "$2" ] || [ "$2" == "NULL" ]; then subDirSearchParam="-maxdepth 1"; fi

filesList=( $(find . $subDirSearchParam -type f -iname \*.$inputFileType -printf "%P\n" ) )

nFilesInList=${#filesList[@]}
i=0
# iterates over and operate on all resulting the resulting inputFileType-s:
for file in ${filesList[@]}
do
	i=$((i + 1))
	# inkscape CLI documentation: https://wiki.inkscape.org/wiki/index.php/Using_the_Command_Line
	# also via writing to help file: inkscape --action-list > halp.txt
	echo "working on file $file . . . ($i of $nFilesInList)"
	# if the input file format is SVG, add a flag to export plain SVG:
	if [ "$inputFileType" == 'svg' ]
	then
		inkscape --export-filename="$file" --export-plain-svg --actions="select-all;fit-canvas-to-selection" $file
	else
		inkscape --export-filename="$file" --actions="select-all;fit-canvas-to-selection" $file
	fi
done
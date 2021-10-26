# DESCRIPTION
# Alters any vector file that InkScape can edit to have the viewable area set to the drawing, with no padding. Not very efficient (load, operation and save is slow per file), but the only way I've found at the moment to do this.

# DEPENDENCY
# inkscape installed and in your PATH.

# USAGE
# Run with these parameters:
# - $1 source image type
# For example:
#    inkscapeResizeCanvasToDrawing.sh svg


# CODE
if [ ! "$1" ]
then
	printf "\nNo parameter \$1 (source file type) passed to script. Exit."
	exit 1
else
	source_file_type=$1
fi

files=( $(find . -maxdepth 1 -name "*.$source_file_type" -printf "%f\n") )
for file in ${files[@]}
do
	echo working on file $file . . .
# re: https://wiki.inkscape.org/wiki/index.php/Using_the_Command_Line#Modify_files
# re: https://how-to.fandom.com/wiki/How_to_use_Inkscape_in_commandline_mode/List_of_verbs
	inkscape $file --batch-process --with-gui --actions="FitCanvasToDrawing;FileSave;FileClose"
done

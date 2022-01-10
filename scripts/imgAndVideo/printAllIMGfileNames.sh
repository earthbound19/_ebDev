# DESCRIPTION
# Prints a list of all files matching many image etc. file types in the current directory, and optionally all subdirectories. To create an array from the list, see USAGE.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Anything, for example the word 'BROGNALF', which will cause the script to find and print image file names also in subdirectories (and not only the current directory). If omitted, the script only finds and prints file names from the current directory. To use parameter $2 (read on) but not this, pass this as the word 'NULL'.
# - $2 OPTIONAL. Anything, for example the phrase 'RETURN OF BROGNALF' encased in single quote marks, which will cause the script to print full paths (not relative paths).
# Example command to find and print files from the current directory only:
#    printAllIMGfileNames.sh
# Example command to find and print files from the current directory and all subdirectories:
#    printAllIMGfileNames.sh BROGNALF
# To use this from another script to create an array from the output, do this:
#    allIMGfileNamesArray=( $(printAllIMGfileNames.sh) )
# -- you may then iterate through it like this:
#    for element in ${allIMGfileNamesArray[@]}; do <something with $element>; done
# NOTE
# Because some tools are silly and create files with uppercase extensions, this script searches for both lowercase and uppercase extensions of every file type in its list.


# CODE
# If no parameter one, maxdepthParameter will be left at default, which causes find to search only the current directory:
maxdepthParameter='-maxdepth 1'
# If parameter one is passed to script, that changes to nothing, and find's default recursive search will be used (as no maxdepth switch will be passed) :
if [ "$1" ] && [ "$1" != "NULL" ]; then maxdepthParameter=''; fi

# array of file types in lowercase; will programmatically build `find` command that searches for these *and* uppercase versions (because some devices and programs are silly and write uppercase extensions) :
filetypes=(
bmp
cr2
crw
dng
gif
heic
jpeg
jpg
kra
ora
png
psb
psd
ptg
raw
rif
riff
tga
tif
tiff
)

# build string listing lowercase and also uppercase extensions list section for `find` command:
for type in ${filetypes[@]}
do
	typesParam+="-o -iname \*.$type -o -iname \*.${type^^} "
done

# I'm only getting this to work in a temp script that I create, write the command to, executed and then delete. By itself with whatever escaping I find, or in a variable expanded to a command, it breaks; CHORFL is just to meet a requirement of starting the list withuot -o:
# if $2 was passed to the script, use find command that will print full paths (via ~+ and no -printf "%P\n") :
if [ "$2" ]
then
	echo "find ~+ $maxdepthParameter -type f \( -iname \*.CHORFL $typesParam \)" > tmpScript_bxJZuSvKq.sh
# otherwise use command that prints relative paths:
else
	echo "find ./ $maxdepthParameter -type f \( -iname \*.CHORFL $typesParam \) -printf \"%P\n\"" > tmpScript_bxJZuSvKq.sh
fi

./tmpScript_bxJZuSvKq.sh
rm ./tmpScript_bxJZuSvKq.sh
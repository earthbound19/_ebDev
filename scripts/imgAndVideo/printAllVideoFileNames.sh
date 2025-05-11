# DESCRIPTION
# Variant of `printAllIMGfileNames.sh` but for video files. Prints a list of all files matching many video file types in the current directory, and optionally all subdirectories. To create an array from the list, see USAGE.

# USAGE
# Run without any parameter:
#    printAllVideoFileNames.sh
# To use this from another script to create an array from the output, do this:
#    allVideoFileNamesArray=($(printAllVideoFileNames.sh))
# -- you may then iterate through it like this:
#    for element in ${allVideoFileNamesArray[@]}; do <something with $element>; done
# By default, the script only prints files in the current directory, but if you pass any parameter to the script (for example the word 'BROGNALF'), it will also (find and) print image file names from subdirectories:
#    printAllVideoFileNames.sh BROGNALF
# NOTE
# Because some tools are silly and create files with uppercase extensions, this script searches for both lowercase and uppercase extensions of every file type in its list.


# CODE
# If no parameter one, maxdepthParameter will be left at default, which causes find to search only the current directory:
maxdepthParameter='-maxdepth 1'
# If parameter one is passed to script, that changes to nothing, and find's default recursive search will be used (as no maxdepth switch will be passed) :
if [ "$1" ]; then maxdepthParameter=''; fi

# array of file types in lowercase; will programmatically build `find` command that searches for these *and* uppercase versions (because some devices and programs are silly and write uppercase extensions) :
filetypes=(
3g2
3gp
3gp2
3gpp
amv
asf
avi
avc
bik
divx
dpg
dv
dvr-ms
evo
f4v
flv
hdmov
k3g
m1v
m2t
m2ts
m2v
m4b
m4p
m4v
mk3d
mkv
mov
mp2v
mp4
mp4v
mpe
mpeg
mpg
mpv2
mpv4
mqv
mts
mxf
nsv
ogm
ogv
qt
ram
rm
rmvb
skm
swf
tp
tpr
trp
ts
vob
webm
wm
wmv
xvid
)

# DEPRECATED when developing this improved approach: append uppercase versions of all of those to the same array: NO NEED TO DO THIS because I search with the case-insensitive flag -iname (with the find command) :
# for type in ${filetypes[@]}
# do
	# filetypes+=(${type^^})
# done

allFoundVideoFiles=$()
# for every file type in the file types array, run a search command and add the result to the array:
#    working template search command:
#    find ./ $maxdepthParameter -type f -iname \*.mp4 -printf "%P\n"
for type in ${filetypes[@]}
do
	theseFoundVideoTypes=($(find ./ $maxdepthParameter -type f -iname \*.$type -printf "%P\n"))
	# append those findings (that array) to allFoundVideoFiles:
	allFoundVideoFiles=("${allFoundVideoFiles[@]}" "${theseFoundVideoTypes[@]}")
done

# print them all
for file in ${allFoundVideoFiles[@]}
do
	echo $file
done
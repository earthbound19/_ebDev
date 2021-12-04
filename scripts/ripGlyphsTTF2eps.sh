# DESCRIPTION
# Rips all basic Latin Unicode glyphs out of a .ttf font and generates individual ~.eps (PostScript) files of them.

# DEPENDENCY
# ttf2eps from FontForge, which (I think) must be manually compiled for your system. you may compile it via ttf2eps.c, included in this repo. I have a win32-or-64 binary of it in _ebSuperBin.

# USAGE
# Run with one parameter, which is the name of a true-type font file in the same directory from which you call this script. For example:
#    ripGlyphsTTF2eps.sh NotoSansMono-Black.ttf
# To extract all glyphs you don't need this script; just run:
#    ttf2eps -all <ttfFileNameInYourDirectory>
# NOTES
# You may get fewer or no errors (ripping from ttf to eps glyphs, or in subsequent eps to png etc. conversion) if you load a font in FontForge, then export it to a new .ttf font. That is also a path to extracting glyphs from fonts in formats originally other than .ttf.


# CODE
# USAGE OF TTF2EPS via ttf2eps --help, and my notes:
# ttf2eps [-all] {-glyph num | -name name | -Unicode hex | -uni hex} truetypefile
# Examples:
#    ttf2eps -Unicode 0021 arial.ttf
# --may produce e.g. glyph4.eps (an exclamation mark)! :)
#
#    ttf2eps.exe -all Aetherfox.TTF
# -- will extract all glyphs from the font to .eps files named after each glyph.
#
# To build ttf2eps via gcc, but as of a newer version of the c file it has other dependencies I haven't wrangled into build shape:
# gcc ttf2eps.c -o ttf2eps

# basic Latin Unicode code page ref: http://www.fileformat.info/info/Unicode/block/index.htm
# OR: http://www.fileformat.info/info/Unicode/block/basic_latin/list.htm
# extract glyphs in basic Latin range:
teh_codes=(
0021
0022
0023
0024
0025
0026
0027
0028
0029
002A
002B
002C
002D
002E
002F
0030
0031
0032
0033
0034
0035
0036
0037
0038
0039
003A
003B
003C
003D
003E
003F
0040
0041
0042
0043
0044
0045
0046
0047
0048
0049
004A
004B
004C
004D
004E
004F
0050
0051
0052
0053
0054
0055
0056
0057
0058
0059
005A
005B
005C
005D
005E
005F
0060
0061
0062
0063
0064
0065
0066
0067
0068
0069
006A
006B
006C
006D
006E
006F
0070
0071
0072
0073
0074
0075
0076
0077
0078
0079
007A
007B
007C
007D
007E
)

# (re)create a temp working dir so we don't clobber any .eps files (work in the temp dir) :
rm -rf tmp_working_dir__VbUM3EynUyPhg7
mkdir tmp_working_dir__VbUM3EynUyPhg7

pushd .
cd tmp_working_dir__VbUM3EynUyPhg7
cp ../$1 .

for element in ${teh_codes[@]}
do
	ttf2eps -Unicode $element $1
done

epsArray=(`find . -maxdepth 1 -type f -iname \*.eps -printf '%f\n'`)

# Rename resultant files after font file name.
fontFileNameNoExt=${1%.*}
# To sort them into a folder named after the font file name:
if [ ! -d ../$"$fontFileNameNoExt"_glyphs ]
then
	mkdir ../"$fontFileNameNoExt"_glyphs
fi

mv *.eps ../"$fontFileNameNoExt"_glyphs

popd
rm -rf tmp_working_dir__VbUM3EynUyPhg7

echo "DONE. Ripped glyphs are in directory ""$fontFileNameNoExt""_glyphs. You may wish to run allEPS2ims.sh in that directory to convert them all .e.g. to pngs."
# DESCRIPTION:
# Creates a large image of a palette from an input file, via an ffmpeg filter and nconvert.

# USAGE:
# getPalette.sh name_of_image_or_video_to_analyze.png

ffmpeg -y -i $1 -vf palettegen $1_palette.png
nconvert -ratio -rtype quick -resize 800 800 -o $1_palette_enbiggened.png $1_palette.png
rm $1_palette.png
# DESCRIPTION
# Renders any image source as a composition of flat primitive shapes, via a Go package named "primitive" (this is a wrapper for primitive). Output file names are the same as input only possibly in a different image format, but add `_primitive_count_<count>_mode_<mode>__<8RandomChars>` to the file name (extrapolate the meaning--it doesn't literally use angle brackets in the output file name). It adds random strings to the end of the file name, so that you can run it twice on the same input and get a different result (it is different every time!) and keep the original and the new alongside each other. Also, it overrides the (at this writing) default behavior of reducing the image by getting and passing the largest dimension to the -s switch.

# DEPENDENCIES
# Go, and the Go package named "primitive;" install it with:
#    go get -u github.com/fogleman/primitive
# --and the Go bin or wherever it installs said package in your $PATH.

# USAGE
# Run with these parameters:
# - $1 input image file name. Must be jpg or png format.
# - $2 OPTIONAL. How many primitive shapes will be in the render. Default 100 if omitted.
# - $3 OPTIONAL. Render mode, which is a number from 0 to 8. Default 5 (rotated rectangle) if omitted.
# - $4 OPTIONAL. Image output file format (extension without the period '.'). Defaults to png if omitted. Valid options are png, jpg, svg, gif. Output for png, jpg and gif will be raster, and gif will be an animation showing the accumulation of shapes until it is complete. An svg image will be a vector. For PNG and SVG outputs, you can also include %d, %03d, etc. in the filename. In this case, each frame will be saved separately.
# Example that will use input_image.png and make 100 rectangles, and render to a .png image:
#    primitive_render.sh input_image.png 100 5 png
# NOTES
# You can also just use the go package directly, as the basic usage is, well, basic:
#    primitive -i input.png -o output.png -n 100 -m 4
# To directly use the go package, you can use the -o flag multiple times. This way you can save both a PNG and an SVG, for example.
# SEE ALSO
# https://gist.github.com/Everlag/8344fa7c9234900ba2cb851581c62599 re https://github.com/fogleman/primitive/issues/28 -- and see other things there


# CODE
if [ -z "$1" ]; then echo "NO INPUT FILE NAME. Re-run and pass this script an input image file name."; exit; else filename=$1; fi
if [ -z "$2" ]; then count=100; else count=$2; fi
if [ -z "$3" ]; then mode=5; else mode=$3; fi
if [ -z "$4" ]; then output_format=png; else output_format=$4; fi

# override default shrinking of images by default in this script :) by getting largest dimension and passing it later via -s:
identStr=`gm identify $filename`
		# echo $identStr
xPix=`echo $identStr | sed 's/.* \([0-9]\{1,\}\)x[0-9]\{1,\}.*/\1/g' | tr -d '\15\32'`
yPix=`echo $identStr | sed 's/.* [0-9]\{1,\}x\([0-9]\{1,\}\).*/\1/g' | tr -d '\15\32'`
largestDimension=`echo $(( $xPix > $yPix ? $xPix : $yPix ))`

fileNameNoExt=${filename%.*}
randomString=`cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 8`
primitive -i $filename -o "$fileNameNoExt"_primitive_count_"$count"_mode_"$mode"__"$randomString".$output_format -n $count -m $mode -s $largestDimension


# REFERENCE
# From the CLI program's own help output and from README.md at github: https://github.com/fogleman/primitive

# USAGE of the tool this script calls, which is named "primitive:"
# primitive [OPTIONS] -i input -o output -n count
  # -a int
        # alpha value (default 128)
  # -bg string
        # background color (hex)
  # -i string
        # input image path
  # -j int
        # number of parallel workers (default uses all cores)
  # -m int
        # 0=combo 1=triangle 2=rect 3=ellipse 4=circle 5=rotatedrect 6=beziers 7=rotatedellipse 8=polygon (default 1)
  # -n value
        # number of primitives
  # -nth int
        # save every Nth frame (put "%d" in path) (default 1)
  # -o value
        # output image path
  # -r int
        # resize large input images to this size (default 256)
  # -rep int
        # add N extra shapes per iteration with reduced search
  # -s int
        # output image size (default 1024)
  # -v    verbose
  # -vv
        # very verbose
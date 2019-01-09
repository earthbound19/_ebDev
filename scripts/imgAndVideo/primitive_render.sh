# DESCRIPTION
# Renders any image source as a composition of flat primitive shapes, via a Go package named "primitive" (this is a wrapper for primitive). Output file names are the same as input only possibly in a different image format, but add _primitive_count_<count>_mode_<mode>__<8RandomChars> to the file name (extrapolate the meaning--it doesn't literally use angle brackets in the output file name). It adds random strings to the end so you can run it twice on the same input and get a different result (it is different every time!) and keep the original and the new alongside each other.

# USAGE
# NOTE that the positional arguments that follow have changed from an earlier version:
# ./thisScript.sh input_image.png 100 5 png
# where:
# - input_image.png (as an example) is an input image file name. Required.
# - 100 (as an example) is how many primitive shapes will be in the render. Default 100 if omitted.
# - 4 is the mode number (see below reference), which may be 0 to 8. Default 5 (rotated rectangle) if omitted.
# - png is an output image format. Valid options are png, jpg, svg, gif (see reference comments at end of script or see primitive CLI reference). Default png if omitted.
# OR, just use the go package directly, as the basic usage is, well, basic:
# primitive -i input.png -o output.png -n 100 -m 4

# NOTE that input images must be png or jpg format images.

# DEPENDENCIES
# Go, and said Go package; install it with:
# go get -u github.com/fogleman/primitive
# --and the Go bin or wherever it installs said package in your $PATH.


# CODE
if [ -z ${1+x} ]; then echo "NO INPUT FILE NAME. Re-run and pass this script an input image file name."; exit; else filename=$1; fi
if [ -z ${2+x} ]; then count=100; else count=$2; fi
if [ -z ${3+x} ]; then mode=5; else mode=$3; fi
if [ -z ${4+x} ]; then output_format=png; else output_format=$4; fi

fileNameNoExt=${filename%.*}
randomString=`cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 8`
primitive -i $filename -o "$fileNameNoExt"_primitive_count_"$count"_mode_"$mode"__"$randomString".$output_format -n $count -m $mode


# REFERENCE
# From the CLI program's own help output and from README.md at github: https://github.com/fogleman/primitive

# Usage: primitive [OPTIONS] -i input -o output -n count
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

# Output Formats
# Depending on the output filename extension provided, you can produce different types of output.

# PNG: raster output
# JPG: raster output
# SVG: vector output
# GIF: animated output showing shapes being added - requires ImageMagick (specifically the convert command)
# For PNG and SVG outputs, you can also include %d, %03d, etc. in the filename. In this case, each frame will be saved separately.

# You can use the -o flag multiple times. This way you can save both a PNG and an SVG, for example.
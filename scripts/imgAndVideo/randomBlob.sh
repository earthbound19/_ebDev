# DESCRIPTION
# DEPRECATED. See randomBlob.py. This script is much slower. Generates a raster image of a random blob using ImageMagick. Black blob on white created from randomly distributed points connected by thick lines or splines, then Gaussian blurred and thresholded. NOTE, however, that this does many bash utility calls and is relatively quite inefficient, and there is a far faster replacement, as mentioned, ergo the deprecation.

# The concept and algorithm design were originally created by Fred Weinhaus. This 
# is a clean-room reimplementation written from functional specifications 
# derived from his work, without direct reference to the original source code, by a Large Language Model, with user refinement and direction on implementation adaptations. All implementation details, including the Kochanek-Bartels spline mathematics and point generation algorithms, have been independently implemented based on the specifications.

# The script provides extensive control over point distribution, connection methods, 
# blurring, and thresholding parameters, allowing for a wide variety of organic blob 
# shapes to be generated programmatically.

# DEPENDENCIES
# - ImageMagick 7, for all image processing operations
# - bc (basic calculator), for floating-point arithmetic
# - Standard Unix tools: awk, sed, cut, expr, mktemp

# Platform Support:
# - Linux/Unix: Should work natively with standard toolchain, untested
# - macOS: Should work with ImageMagick installed via Homebrew/MacPorts, untested
# - Windows: Requires MSYS2, Cygwin, or WSL with ImageMagick 7 installed. Some rudimentary testing done; entire features may not work, or bugs may abound!
#   The script uses bash-specific features and should work in any POSIX-compliant
#   environment that provides the required dependencies.

# USAGE
# randomblob.sh [options]

# Options:
#   -n numpts        Number of random points (default: 12)
#   -l linewidth     Width of connecting lines (default: 13)
#   -i isize         Inner region size/diameter (default: 400)
#   -d dimensions    Output image dimensions WxH or single value (default: 512)
#   --shape shape    Inner region shape: square, disk (default: disk)
#   -b blur          Gaussian blur sigma (default: 33)
#   -t threshold     Threshold percentage 1-99 (default: 25)
#   -k kind          Point distribution: uniform, gaussian (default: uniform)
#   -g gsigma        Gaussian distribution sigma (default: 67)
#   -c constrain     Constrain to inner region: yes, no (default: yes)
#   --drawtype type  Connection method: line, spline (default: spline)
#   -T tension       Spline tension (default: 0, can be negative)
#   -C continuity    Spline continuity (default: 0, can be negative)
#   -B bias          Spline bias (default: 0, can be negative)
#   -S seed          Random seed (any positive integer, will be hashed if too large) (default: random)
#   -p pixinc        Spline interpolation pixel increment (default: 2)
#   -f file1         Point pairs file - exact count (x,y per line in [0,1))
#   -F file2         Point pairs file - indexed, seed as start index
#   -m maskfile      Mask image file (white region on black background)
#   -o outfile       Output image file (auto-generated if omitted)
#   --debug          Print intermediate values
#   --save           Save intermediate connected points image

# Examples:
#   randomblob.sh
#   randomblob.sh -n 20 -l 20 -b 50 -t 30 --drawtype line
#   randomblob.sh -k gaussian -g 100 --shape square -d 1024 -o blob.png
#   randomblob.sh -f points.txt -T 0.5 -C -0.3

# NOTES
# - This has not been extensively tested for intended functionality or workability of all options and arguments.
# - Point coordinates from files (-f, -F) must be in range [0,1) and will be mapped
#   to the output image dimensions
# - The spline implementation uses Kochanek-Bartels (TCB) splines for smooth curves
# - Larger pixel increment values (-p) speed up rendering but may reduce smoothness
# - The mask file, if provided, overrides the inner region constraint
# - All numeric parameters are validated before processing
# - Temporary files are automatically cleaned up on exit or interrupt
# - The script sets MAGICK_PRECISION=6 for consistent decimal handling
# - Large seed values (> 2^63-1) are automatically hashed to a valid 32-bit range
# - If no output file is specified with -o, a filename will be auto-generated in the format:
#   randomBlob_S<seed>_n<points>_p<pixinc>_l<linewidth>.png

# LICENSE
# This software is provided as-is, with no warranties of any kind. Written 2026-03-11, based on specifications derived from Fred Weinhaus's original concept.

# This work is hereby dedicated to the public domain. To the extent possible under law,
# the author has waived all copyright and related or neighboring rights to this work.

# See: https://creativecommons.org/publicdomain/zero/1.0/

# CODE
# The functional script begins below this line.
# -----------------------------------------------------------------------------

# Set ImageMagick precision
export MAGICK_PRECISION=6

set -e  # Exit on error
set -u  # Exit on undefined variable
# set -x

# Default values
numpts=12
linewidth=13
isize=400
dimensions="512"
shape="disk"
blur=33
threshold=25
kind="uniform"
gsigma=67
constrain="yes"
drawtype="spline"  # Default to spline as per spec
tension=0
continuity=0
bias=0
seed=""  # Will be auto-generated if not provided
pixinc=2
file1=""
file2=""
maskfile=""
outfile=""
debug="no"
save="no"

# Temporary files
temp_files=()
cleanup() {
    rm -f "${temp_files[@]}"
}
trap cleanup EXIT INT TERM

# Function to generate auto filename
generate_auto_filename() {
    local seed_val=$1
    local numpts_val=$2
    local pixinc_val=$3
    local linewidth_val=$4
    echo "randomBlob_magick_S${seed_val}_n${numpts_val}_p${pixinc_val}_l${linewidth_val}.png"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n) numpts="$2"; shift 2 ;;
        -l) linewidth="$2"; shift 2 ;;
        -i) isize="$2"; shift 2 ;;
        -d) dimensions="$2"; shift 2 ;;
        --shape) shape="$2"; shift 2 ;;
        -b) blur="$2"; shift 2 ;;
        -t) threshold="$2"; shift 2 ;;
        -k) kind="$2"; shift 2 ;;
        -g) gsigma="$2"; shift 2 ;;
        -c) constrain="$2"; shift 2 ;;
        --drawtype) drawtype="$2"; shift 2 ;;
        -T) tension="$2"; shift 2 ;;
        -C) continuity="$2"; shift 2 ;;
        -B) bias="$2"; shift 2 ;;
        -S) seed="$2"; shift 2 ;;
        -p) pixinc="$2"; shift 2 ;;
        -f) file1="$2"; shift 2 ;;
        -F) file2="$2"; shift 2 ;;
        -m) maskfile="$2"; shift 2 ;;
        -o) outfile="$2"; shift 2 ;;
        --debug) debug="yes"; shift ;;
        --save) save="yes"; shift ;;
        -*)
            echo "Error: Unknown option $1"
            exit 1
            ;;
        *)
            echo "Error: Unexpected argument $1 (all options are now named switches)"
            exit 1
            ;;
    esac
done

# Generate random seed if not provided
if [[ -z "$seed" ]]; then
    # Generate random seed in range 1-32767 (bash RANDOM range)
    seed=$(( (RANDOM % 32766) + 1 ))
    echo "Generated random seed: $seed (use -S $seed to reproduce this blob)" >&2
fi

# Generate output filename if not specified
if [[ -z "$outfile" ]]; then
    outfile=$(generate_auto_filename "$seed" "$numpts" "$pixinc" "$linewidth")
    echo "Auto-generating output filename: $outfile" >&2
fi

# Validate numeric parameters
validate_positive_int() {
    # Check if it's a positive integer (allowing for very large numbers)
    if ! [[ "$2" =~ ^[0-9]+$ ]] || [[ "$2" -eq 0 ]]; then
        echo "Error: $1 must be a positive integer"
        exit 1
    fi
}

validate_positive_float() {
    if ! [[ "$2" =~ ^[0-9]*\.?[0-9]+$ ]] || [[ $(echo "$2 <= 0" | bc) -eq 1 ]]; then
        echo "Error: $1 must be a positive number"
        exit 1
    fi
}

validate_int_range() {
    if ! [[ "$2" =~ ^[0-9]+$ ]] || [[ "$2" -lt 1 ]] || [[ "$2" -gt 99 ]]; then
        echo "Error: $1 must be an integer between 1 and 99"
        exit 1
    fi
}

validate_positive_int "-n" "$numpts"
validate_positive_int "-l" "$linewidth"
validate_positive_int "-i" "$isize"
validate_positive_float "-b" "$blur"
validate_int_range "-t" "$threshold"
validate_positive_float "-g" "$gsigma"
validate_positive_int "-S" "$seed"
validate_positive_int "-p" "$pixinc"

# Parse output dimensions
if [[ "$dimensions" =~ ^[0-9]+x[0-9]+$ ]]; then
    owidth=$(echo "$dimensions" | cut -d'x' -f1)
    oheight=$(echo "$dimensions" | cut -d'x' -f2)
else
    owidth="$dimensions"
    oheight="$dimensions"
fi
validate_positive_int "output width" "$owidth"
validate_positive_int "output height" "$oheight"

# Validate shape
if [[ "$shape" != "square" && "$shape" != "disk" ]]; then
    echo "Error: shape must be 'square' or 'disk'"
    exit 1
fi

# Validate kind
if [[ "$kind" != "uniform" && "$kind" != "gaussian" ]]; then
    echo "Error: kind must be 'uniform' or 'gaussian'"
    exit 1
fi

# Validate constrain
if [[ "$constrain" != "yes" && "$constrain" != "no" ]]; then
    echo "Error: constrain must be 'yes' or 'no'"
    exit 1
fi

# Validate drawtype
if [[ "$drawtype" != "line" && "$drawtype" != "spline" ]]; then
    echo "Error: drawtype must be 'line' or 'spline'"
    exit 1
fi

# Validate files if specified
if [[ -n "$file1" && ! -f "$file1" ]]; then
    echo "Error: Point pairs file not found: $file1"
    exit 1
fi
if [[ -n "$file2" && ! -f "$file2" ]]; then
    echo "Error: Point pairs file not found: $file2"
    exit 1
fi
if [[ -n "$maskfile" && ! -f "$maskfile" ]]; then
    echo "Error: Mask file not found: $maskfile"
    exit 1
fi

# Normalize seed for bash's RANDOM (which only supports 0-32767)
if [[ $seed -gt 32767 ]]; then
    # Simple modulo to get into valid range, ensuring non-zero
    seed=$(( (seed % 32766) + 1 ))
    if [[ "$debug" == "yes" ]]; then
        echo "  Note: Seed normalized to $seed for bash RANDOM" >&2
    fi
fi
RANDOM="$seed"

# Debug output
if [[ "$debug" == "yes" ]]; then
    echo "Configuration:" >&2
    echo "  Points: $numpts" >&2
    echo "  Line width: $linewidth" >&2
    echo "  Inner size: $isize" >&2
    echo "  Output dimensions: ${owidth}x${oheight}" >&2
    echo "  Shape: $shape" >&2
    echo "  Blur: $blur" >&2
    echo "  Threshold: $threshold" >&2
    echo "  Distribution: $kind" >&2
    echo "  Gaussian sigma: $gsigma" >&2
    echo "  Constrain: $constrain" >&2
    echo "  Draw type: $drawtype" >&2
    echo "  Seed: $seed" >&2
    echo "  Pixel increment: $pixinc" >&2
    echo "  Output file: $outfile" >&2
fi

# Function to generate random points
generate_points() {
    local points_file="$1"
    local count=0
    
    # Handle file-based points
    if [[ -n "$file1" ]]; then
        # Read exactly N points from file
        mapfile -t lines < "$file1"
        if [[ ${#lines[@]} -lt $numpts ]]; then
            echo "Error: File $file1 has fewer than $numpts lines" >&2
            exit 1
        fi
        for ((i=0; i<numpts; i++)); do
            echo "${lines[$i]}" >> "$points_file"
        done
        return
    elif [[ -n "$file2" ]]; then
        # Read N points starting from seed
        mapfile -t lines < "$file2"
        if [[ ${#lines[@]} -lt $((seed + numpts - 1)) ]]; then
            echo "Error: File $file2 has fewer than $((seed + numpts - 1)) lines" >&2
            exit 1
        fi
        for ((i=seed-1; i<seed-1+numpts; i++)); do
            echo "${lines[$i]}" >> "$points_file"
        done
        return
    fi
    
    # Generate random points
    local center_x=$(( (owidth - 1) / 2 ))
    local center_y=$(( (oheight - 1) / 2 ))
    local half_inner=$(( isize / 2 ))
    
    while [[ $count -lt $numpts ]]; do
        # Generate p1 and p2
        local p1=$(echo "scale=10; $RANDOM / 32767" | bc)
        local p2=$(echo "scale=10; 1 - ($RANDOM / 32767)" | bc)
        
        local x y valid=1
        
        if [[ "$kind" == "uniform" ]]; then
            if [[ "$shape" == "disk" ]]; then
                # Uniform distribution on disk
                local r=$(echo "scale=10; sqrt($p1) * $half_inner" | bc)
                local angle=$(echo "scale=10; 2 * 3.14159 * $p2" | bc)
                local dx=$(echo "scale=10; $r * c($angle)" | bc -l)
                local dy=$(echo "scale=10; $r * s($angle)" | bc -l)
                x=$(echo "scale=0; ($center_x + $dx)/1" | bc)
                y=$(echo "scale=0; ($center_y + $dy)/1" | bc)
            else
                # Uniform distribution on square
                x=$(echo "scale=0; ($isize * ($p1 - 0.5) + $center_x)/1" | bc)
                y=$(echo "scale=0; ($isize * ($p2 - 0.5) + $center_y)/1" | bc)
            fi
        else
            # Gaussian distribution
            local r=$(echo "scale=10; sqrt(-2 * l($p1))" | bc -l)
            local theta=$(echo "scale=10; 2 * 3.14159 * $p2" | bc)
            local dx=$(echo "scale=10; $gsigma * $r * c($theta)" | bc -l)
            local dy=$(echo "scale=10; $gsigma * $r * s($theta)" | bc -l)
            x=$(echo "scale=0; ($center_x + $dx)/1" | bc)
            y=$(echo "scale=0; ($center_y + $dy)/1" | bc)
            
            # Constrain to inner region if requested
            if [[ "$constrain" == "yes" ]]; then
                if [[ "$shape" == "disk" ]]; then
                    local dx2=$(echo "$x - $center_x" | bc)
                    local dy2=$(echo "$y - $center_y" | bc)
                    local dist=$(echo "scale=10; sqrt($dx2^2 + $dy2^2)" | bc)
                    if [[ $(echo "$dist > $half_inner" | bc) -eq 1 ]]; then
                        valid=0
                    fi
                else
                    local xmin=$(echo "$center_x - $half_inner" | bc)
                    local xmax=$(echo "$center_x + $half_inner" | bc)
                    local ymin=$(echo "$center_y - $half_inner" | bc)
                    local ymax=$(echo "$center_y + $half_inner" | bc)
                    if [[ $(echo "$x < $xmin || $x > $xmax" | bc) -eq 1 ]] || \
                       [[ $(echo "$y < $ymin || $y > $ymax" | bc) -eq 1 ]]; then
                        valid=0
                    fi
                fi
            fi
        fi
        
        if [[ $valid -eq 1 ]]; then
            echo "$x,$y" >> "$points_file"
            count=$((count + 1))
        fi
    done
}

# Function to draw spline segment
draw_spline_segment() {
    local x0=$1; local y0=$2
    local x1=$3; local y1=$4
    local x2=$5; local y2=$6
    local x3=$7; local y3=$8
    local tension=$9; local continuity=${10}; local bias=${11}
    local pixinc=${12}
    
    # Calculate tangents
    local t1x=$(echo "scale=10; (1-$tension)*(1-$bias)*(1-$continuity)*($x2-$x1)/2 + (1-$tension)*(1+$bias)*(1+$continuity)*($x1-$x0)/2" | bc -l)
    local t1y=$(echo "scale=10; (1-$tension)*(1-$bias)*(1-$continuity)*($y2-$y1)/2 + (1-$tension)*(1+$bias)*(1+$continuity)*($y1-$y0)/2" | bc -l)
    local t2x=$(echo "scale=10; (1-$tension)*(1-$bias)*(1+$continuity)*($x3-$x2)/2 + (1-$tension)*(1+$bias)*(1-$continuity)*($x2-$x1)/2" | bc -l)
    local t2y=$(echo "scale=10; (1-$tension)*(1-$bias)*(1+$continuity)*($y3-$y2)/2 + (1-$tension)*(1+$bias)*(1-$continuity)*($y2-$y1)/2" | bc -l)
    
    # Hermite coefficients for x
    local a3x=$(echo "scale=10; 2*$x1 - 2*$x2 + $t1x + $t2x" | bc -l)
    local a2x=$(echo "scale=10; -3*$x1 + 3*$x2 - 2*$t1x - $t2x" | bc -l)
    local a1x=$t1x
    local a0x=$x1
    
    # Hermite coefficients for y
    local a3y=$(echo "scale=10; 2*$y1 - 2*$y2 + $t1y + $t2y" | bc -l)
    local a2y=$(echo "scale=10; -3*$y1 + 3*$y2 - 2*$t1y - $t2y" | bc -l)
    local a1y=$t1y
    local a0y=$y1
    
    # Interpolate points
    local points=""
    local steps=$(( 100 / pixinc ))
    for ((s=0; s<=steps; s++)); do
        local t=$(echo "scale=10; $s * $pixinc / 100" | bc)
        if [[ $(echo "$t > 1" | bc) -eq 1 ]]; then
            t=1
        fi
        
        local xt=$(echo "scale=10; (($a3x * $t + $a2x) * $t + $a1x) * $t + $a0x" | bc -l)
        local yt=$(echo "scale=10; (($a3y * $t + $a2y) * $t + $a1y) * $t + $a0y" | bc -l)
        
        # Round to integers
        local xi=$(echo "scale=0; $xt / 1" | bc)
        local yi=$(echo "scale=0; $yt / 1" | bc)
        
        points="$points $xi,$yi"
    done
    
    echo "$points"
}

# Main execution
tmp_points=$(mktemp)
temp_files+=("$tmp_points")

# Generate points
generate_points "$tmp_points"

# Read points into arrays
declare -a points_x points_y
while IFS=',' read -r x y; do
    points_x+=("$x")
    points_y+=("$y")
done < "$tmp_points"

if [[ "$debug" == "yes" ]]; then
    echo "Generated points:" >&2
    for ((i=0; i<numpts; i++)); do
        echo "  Point $i: ${points_x[$i]},${points_y[$i]}" >&2
    done
fi

# Create initial white canvas
tmp_canvas=$(mktemp --suffix=.png)
temp_files+=("$tmp_canvas")

magick -size "${owidth}x${oheight}" xc:white "$tmp_canvas"

# Draw connections
if [[ "$drawtype" == "line" ]]; then
    # Draw straight lines as polygon
    polygon=""
    for ((i=0; i<numpts; i++)); do
        polygon="$polygon ${points_x[$i]},${points_y[$i]}"
    done
    # Close the polygon
    polygon="$polygon ${points_x[0]},${points_y[0]}"
    
    magick "$tmp_canvas" \
        -stroke black -strokewidth "$linewidth" -fill none \
        -draw "polygon $polygon" \
        "$tmp_canvas"
else
    # Draw spline
    # Create extended point list for spline (wrap around)
    declare -a spline_x spline_y
    for ((i=0; i<numpts; i++)); do
        spline_x+=("${points_x[$i]}")
        spline_y+=("${points_y[$i]}")
    done
    # Add last point at beginning
    spline_x=("${points_x[$((numpts-1))]}" "${spline_x[@]}")
    spline_y=("${points_y[$((numpts-1))]}" "${spline_y[@]}")
    # Add first two points at end
    spline_x+=("${points_x[0]}" "${points_x[1]}")
    spline_y+=("${points_y[0]}" "${points_y[1]}")
    
    # Draw each segment
    for ((i=1; i<=numpts; i++)); do
        segment=$(draw_spline_segment \
            "${spline_x[$((i-1))]}" "${spline_y[$((i-1))]}" \
            "${spline_x[$i]}" "${spline_y[$i]}" \
            "${spline_x[$((i+1))]}" "${spline_y[$((i+1))]}" \
            "${spline_x[$((i+2))]}" "${spline_y[$((i+2))]}" \
            "$tension" "$continuity" "$bias" "$pixinc")
        
        magick "$tmp_canvas" \
            -stroke black -strokewidth "$linewidth" -fill none \
            -draw "polyline $segment" \
            "$tmp_canvas"
    done
fi

# Save intermediate connected image if requested
if [[ "$save" == "yes" ]]; then
    base="${outfile%.*}"
    cp "$tmp_canvas" "${base}_connected.png"
fi

# Apply Gaussian blur
tmp_blurred=$(mktemp --suffix=.png)
temp_files+=("$tmp_blurred")

magick "$tmp_canvas" -blur 0x"$blur" -auto-level "$tmp_blurred"

# Threshold
thresh_val=$((100 - threshold))
magick "$tmp_blurred" -threshold "${thresh_val}%" "$outfile"

echo "Blob generated successfully: $outfile" >&2
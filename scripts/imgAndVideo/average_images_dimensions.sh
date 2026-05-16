#!/bin/bash
# DESCRIPTION
# Calculates average width and height of all supported images in the current directory
# by leveraging existing printAllIMGfileNames.sh script to generate the file list.
# Uses ImageMagick's identify command for dimension extraction.

# DEPENDENCIES
# - printAllIMGfileNames.sh (must be in PATH)
# - ImageMagick (identify command)

# USAGE
# Run with optional parameter:
#   $1 - Optional: directory path to constrain search (passed to printAllIMGfileNames.sh)
#        If omitted, prints all images from all configured directories.
#
# For example:
#   ./average_images_dimensions.sh
#   ./average_images_dimensions.sh /path/to/images
#
# Output will show:
#   - Each image processed with its dimensions
#   - Total count
#   - Average width and height
#   - Suggested artWidth/artHeight for the Processing sketch

# CODE

# Capture all image filenames using existing script
if [ -n "$1" ]; then
    # If parameter provided, pass it to printAllIMGfileNames.sh
    allImages=( $(printAllIMGfileNames.sh "$1") )
else
    # No parameter, get all images
    allImages=( $(printAllIMGfileNames.sh) )
fi

# Check if any images were found
if [ ${#allImages[@]} -eq 0 ]; then
    echo "ERROR: No images found."
    echo "Make sure printAllIMGfileNames.sh is in your PATH and returns results."
    exit 1
fi

echo "Analyzing ${#allImages[@]} images..."
echo "----------------------------------------"

# Initialize counters
TOTAL_WIDTH=0
TOTAL_HEIGHT=0
IMAGE_COUNT=0

# Iterate over each image
for img in "${allImages[@]}"; do
    # Skip if file doesn't exist (safety check)
    if [ ! -f "$img" ]; then
        echo "  WARNING: File not found: $img"
        continue
    fi
    
    # Get dimensions using ImageMagick identify
    dimensions=$(identify -format "%w %h" "$img" 2>/dev/null)
    
    if [ -n "$dimensions" ]; then
        width=$(echo "$dimensions" | cut -d' ' -f1)
        height=$(echo "$dimensions" | cut -d' ' -f2)
        
        # Validate we got numbers
        if [[ "$width" =~ ^[0-9]+$ ]] && [[ "$height" =~ ^[0-9]+$ ]]; then
            TOTAL_WIDTH=$((TOTAL_WIDTH + width))
            TOTAL_HEIGHT=$((TOTAL_HEIGHT + height))
            IMAGE_COUNT=$((IMAGE_COUNT + 1))
            
            # Print each image's dimensions (optional, comment out for silent run)
            printf "  %3d. %s: %4dx%-4d\n" $IMAGE_COUNT "$(basename "$img")" $width $height
        fi
    fi
done

# Calculate and display averages
if [ $IMAGE_COUNT -gt 0 ]; then
    AVG_WIDTH=$((TOTAL_WIDTH / IMAGE_COUNT))
    AVG_HEIGHT=$((TOTAL_HEIGHT / IMAGE_COUNT))
    
    echo "----------------------------------------"
    echo "STATISTICS:"
    echo "  Images processed: $IMAGE_COUNT"
    echo "  Total width sum: $TOTAL_WIDTH px"
    echo "  Total height sum: $TOTAL_HEIGHT px"
    echo "  AVERAGE DIMENSIONS: ${AVG_WIDTH} x ${AVG_HEIGHT} px"
    
    # Calculate aspect ratio using bc for floating point
    if command -v bc &> /dev/null; then
        ASPECT=$(echo "scale=4; $AVG_WIDTH / $AVG_HEIGHT" | bc)
        echo "  Aspect ratio (w/h): $ASPECT"
    fi
    
    echo ""
    echo "  artWidth = $AVG_WIDTH;"
    echo "  artHeight = $AVG_HEIGHT;"
    
    # Suggest square or keep aspect ratio
    if [ $AVG_WIDTH -eq $AVG_HEIGHT ]; then
        echo "  (Perfect square! Use same value for both dimensions.)"
    elif [ $AVG_WIDTH -gt $AVG_HEIGHT ]; then
        echo "  (Landscape orientation - width > height)"
    else
        echo "  (Portrait orientation - height > width)"
    fi
else
    echo "ERROR: No valid images could be processed."
    echo "Make sure ImageMagick is installed and images are readable."
    exit 1
fi
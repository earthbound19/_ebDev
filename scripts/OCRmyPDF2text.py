# DESCRIPTION
# Uses OCRmyPDF to add an OCR text layer to a PDF, producing both a searchable PDF
# and a sidecar text file. The script provides core control options including
# output file naming, conflict detection, CPU core allocation, and choice between
# two OCR processing methods.

# DEPENDENCIES
# - Python 3.8+
# - ocrmypdf library (install via: pip install ocrmypdf)
# - External binaries (must be installed separately):
# * Tesseract OCR (https://github.com/tesseract-ocr/tesseract)
# * Ghostscript (https://www.ghostscript.com/)
# On MSYS2: pacman -S mingw-w64-x86_64-tesseract-ocr mingw-w64-x86_64-ghostscript
# On Debian/Ubuntu: apt-get install tesseract-ocr ghostscript
# On Windows (non-MSYS2): Install from official distributions and ensure the
# installed binaries are in your PATH

# USAGE
# python script.py -i INPUT.pdf [-o OUTPUT_BASENAME] [-c CORES_PERCENT] [-r]

# Arguments:
# -i, --input          Source PDF file path (required)
# -o, --output         Output basename for generated files without extension
# (optional). If omitted, defaults to input file basename
# + '_OCRmyPDF_convert'
# -c, --cores          Percentage of CPU cores to use, expressed as decimal
# (e.g., 0.75 for 75%). Defaults to 0.75. Valid range:
# 0.01 to 1.0 (clamped automatically)
# -r, --redo-ocr       Use --redo-ocr method instead of default --force-ocr
# (see NOTES for important differences between methods)

# NOTES
# OCR METHODS:

# FORCE_OCR; recommended, default hardcoded if you omit -r --redo-ocr:
# - Converts every page to an image, discarding ALL existing text (both
# visible text and any hidden OCR layers)
# - Rasterizes vector graphics, forms, and printable text into images
# - Runs fresh OCR on all rasterized content
# - More reliable at removing old/inconsistent OCR layers
# - Compatible with preprocessing options (deskew, clean, etc.)
# - Produces larger file size (typically 1.6x+ of original)
# - Recommended for maximum quality and reliability

# REDO_OC; enabled via -r flag:
# - Attempts to remove only the invisible OCR layer while preserving
# visible vector text
# - Runs fresh OCR on image/raster content only
# - Does NOT "extrapolate" or fill gaps intelligently
# - KNOWN ISSUES (per OCRmyPDF documentation and user reports):
# * May fail to completely remove previous OCR layers (Issue #1036, #897)
# * Can introduce spaces inside words, producing garbled output (Issue #736)
# * Incompatible with --deskew, --clean-final, --remove-background (Discussion #1562)
# * May produce inconsistent results across different PDF sources
# - Produces smaller file size (typically ~0.81x of original)
# - Only recommended when file size is critical AND output quality is
# verified on a sample page first

# OUTPUT FILES:
# - Generates two files: {output_basename}.pdf (searchable PDF) and
# {output_basename}.txt (sidecar text file)
# - Sidecar text file contains all recognized text in UTF-8 encoding,
# extracted in left-to-right, top-to-bottom order as determined by
# Tesseract's layout analysis
# - Original PDF's visual appearance is preserved (except when using
# FORCE_OCR, which rasterizes vector content to images)

# CPU CORE ALLOCATION:
# - OCRmyPDF internally uses the OMP_THREAD_LIMIT environment variable
# and joblib's parallel backend for CPU control
# - Percentage is calculated as: max(1, floor(total_cores * percentage))
# - Value is clamped between 1 and total_cores - 1 (leaving at least one
# core free for system processes when possible)

# ERROR HANDLING:
# - Script exits with error if output PDF file already exists (prevents
# accidental overwrites)
# - Validates input file exists and is readable
# - Validates core percentage is within 0.01-1.0 range
# - OCRmyPDF exceptions are propagated to the user with descriptive messages

# SCRIPT ORIGIN:
# - This was created by a human collaborarating with a large language model
# on a dev spec, then saying "go." It has been minimually tested and may
# accidentally explode an unknown demension, or some other geeky crap like
# that.


# CODE

import os
import sys
import argparse
import math
from pathlib import Path
import ocrmypdf


def calculate_threads(percent, total_cores):
    """
    Calculate number of threads based on percentage of available cores.
    
    Args:
        percent (float): Percentage as decimal (0.01 to 1.0)
        total_cores (int): Total available CPU cores
    
    Returns:
        int: Number of threads to use (minimum 1, maximum total_cores)
    """
    if percent <= 0 or percent > 1:
        percent = 0.75  # fallback to default
    
    threads = max(1, math.floor(total_cores * percent))
    # Leave at least one core free if possible, but don't go below 1
    if threads >= total_cores and total_cores > 1:
        threads = total_cores - 1
    
    return max(1, threads)


def validate_input_file(file_path):
    """Validate that input file exists and is a PDF."""
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"Input file not found: {file_path}")
    if not path.is_file():
        raise ValueError(f"Input path is not a file: {file_path}")
    if path.suffix.lower() != '.pdf':
        raise ValueError(f"Input file must be a PDF (got {path.suffix})")
    return path


def validate_output_basename(basename, input_path):
    """
    Validate that output basename doesn't conflict with existing files.
    
    Args:
        basename (str): Desired output basename (without extension)
        input_path (Path): Input file path (for generating default name)
    
    Returns:
        Path: Output PDF path, output text path
    """
    output_pdf = Path(f"{basename}.pdf")
    
    if output_pdf.exists():
        raise FileExistsError(
            f"Output PDF file already exists: {output_pdf}\n"
            f"Please specify a different basename with -o/--output"
        )
    
    output_txt = Path(f"{basename}.txt")
    # Note: We don't error on text file conflict because sidecar generation
    # will overwrite it, but we'll warn the user
    if output_txt.exists():
        print(f"Warning: {output_txt} already exists and will be overwritten", 
              file=sys.stderr)
    
    return output_pdf, output_txt


def main():
    parser = argparse.ArgumentParser(
        description="OCR a PDF using OCRmyPDF with configurable methods and resources",
        epilog="Example: python script.py -i document.pdf -o clean_doc -c 0.5 -r"
    )
    
    parser.add_argument('-i', '--input', required=True,
                        help='Source PDF file path')
    parser.add_argument('-o', '--output',
                        help='Output basename for generated files (without extension). '
                             'Default: input_basename + "_OCRmyPDF_convert"')
    parser.add_argument('-c', '--cores', type=float, default=0.75,
                        help='Percentage of CPU cores to use as decimal (0.01 to 1.0). '
                             'Default: 0.75')
    parser.add_argument('-r', '--redo-ocr', action='store_true',
                        help='Use --redo-ocr method instead of default --force-ocr '
                             '(see NOTES in script header for important caveats)')
    
    args = parser.parse_args()
    
    # Validate core percentage
    if args.cores < 0.01 or args.cores > 1.0:
        print(f"Error: cores percentage must be between 0.01 and 1.0 (got {args.cores})",
              file=sys.stderr)
        sys.exit(1)
    
    # Validate input file
    try:
        input_path = validate_input_file(args.input)
    except (FileNotFoundError, ValueError) as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Determine output basename
    if args.output:
        output_basename = args.output
    else:
        output_basename = f"{input_path.stem}_OCRmyPDF_convert"
    
    # Validate output files
    try:
        output_pdf, output_txt = validate_output_basename(output_basename, input_path)
    except FileExistsError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Determine OCR method
    ocr_method = "REDO_OCR" if args.redo_ocr else "FORCE_OCR"
    
    # Calculate thread count
    total_cores = os.cpu_count() or 4  # Fallback to 4 if detection fails
    threads = calculate_threads(args.cores, total_cores)
    
    print(f"Input file: {input_path}")
    print(f"Output PDF: {output_pdf}")
    print(f"Output text: {output_txt}")
    print(f"OCR method: {ocr_method}")
    print(f"Using {threads} of {total_cores} CPU cores ({args.cores*100:.0f}%)")
    print("-" * 50)
    
    # Additional warnings for REDO_OCR method
    if ocr_method == "REDO_OCR":
        print("NOTE: Using REDO_OCR method. Known issues include:")
        print("  - May fail to completely remove existing OCR layers")
        print("  - Can produce garbled output with spaces inside words")
        print("  - Incompatible with deskewing/cleaning options")
        print("  - Please verify output quality on a sample first")
        print("-" * 50)
    
    # Execute OCR - FIXED API CALL
    try:
        print("Starting OCR processing...")
        
        # CORRECT METHOD: Pass input and output as positional arguments
        # and other options as keyword arguments
        ocrmypdf.ocr(
            str(input_path),           # input_file (positional)
            str(output_pdf),           # output_file (positional)
            sidecar=str(output_txt),
            jobs=threads,
            verbose=True,
            force_ocr=(ocr_method == "FORCE_OCR"),
            redo_ocr=(ocr_method == "REDO_OCR")
        )
        
        print("\n✓ OCR completed successfully!")
        print(f"  Searchable PDF: {output_pdf}")
        print(f"  Extracted text: {output_txt}")
        
    except ocrmypdf.exceptions.PriorOcrFoundError:
        print("\nError: Existing OCR found and --redo-ocr may not handle it correctly.",
              file=sys.stderr)
        print("Try using default --force-ocr method (remove -r flag) for more reliable results.",
              file=sys.stderr)
        sys.exit(1)
    except ocrmypdf.exceptions.MissingDependencyError as e:
        print(f"\nError: Missing required dependency: {e}", file=sys.stderr)
        print("Please ensure Tesseract OCR and Ghostscript are installed and in PATH.",
              file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"\nError during OCR processing: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
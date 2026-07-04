#!/bin/bash
#===============================================================================
# markdown_to_many.sh - Multi-format document renderer using pandoc and LibreOffice
#===============================================================================

# DESCRIPTION:
# ============
# Renders Markdown documents to any / all of multiple formats (ODT, DOCX, PDF, HTML)
# using pandoc and LibreOffice. Configuration is driven by a JSON file.
#
# Markdown documents may in tandem with LibreOffice use a style source .odt
# document for .odt / .docx / .pdf styling. HTML document render via generate-md.
#
# DEPENDENCIES:
# =============
# These must all be installed and in your PATH:
# - pandoc (https://pandoc.org/)
# - LibreOffice (soffice.exe) for DOCX/PDF conversion
# - generate-md (npm package 'generate-md') for HTML generation
# - jq (https://stedolan.github.io/jq/) for JSON parsing
# - Bash 4.0+ (for arrays and readarray)
# Developed on and used with MSYS2 bash (Windows). May be usable
# on other platforms.
#
# USAGE:
# ======
#   ./markdown_to_many.sh [CONFIG_FILE] [--help|-h] [--verbose|-v]
#
#   CONFIG_FILE: Optional path to JSON configuration file.
#                Default: markdown_to_many.json in the current directory
#
# EXAMPLES:
# =========
#   # Run with default config (markdown_to_many.json)
#   ./markdown_to_many.sh
#
#   # Run with custom config file
#   ./markdown_to_many.sh my_resume_config.json
#
#   # Run with verbose output
#   ./markdown_to_many.sh --verbose
#   ./markdown_to_many.sh my_config.json --verbose
#
#   # Display help
#   ./markdown_to_many.sh --help
#   ./markdown_to_many.sh -h
#
# EXAMPLE JSON CONFIG, with all fields and possible array elements; note:
# - you may omit the "active" field and it will assume it's true
#   (you only need to include it if it is set to false)
# - you may omit elements from the "formats" field array (only keeping
#   ones you need, for example "pdf"
# - "auto-open" is optional and only needs to include field array
#   elements you want, same as "formats". auto-open elements
#   invoke the `start` command (maybe unique to MSYS2) to auto-open
#   a completed rendered document of that format
# ----
# markdown_to_many.JSON
#
# [
#    {
#        "active": true,
#        "source": "RAH_Creative_Coder_Resume.md",
#        "style": "style-template.odt",
#        "formats": ["odt", "docx", "pdf", "html"],
#        "auto-open": ["pdf", "html"]
#    },
#    {
#        ..
#        ..<another document JSON array definition>
#    }
# ]
# ----
#
# NOTES:
# ======
#   - ODT is always generated first as it's required for DOCX and PDF conversion
#   - If ODT is not specified as an output format, it's still generated as an
#     intermediate file and then deleted
#   - HTML output uses the jasonm23-foghorn layout hard-coded; if you want
#     another style, hack the script.
#   - HTML output directories are named {basename}_HTML
#   - All output files are created in the current working directory
#   - The script will exit on error (set -e)
#   - PDF viewer (SumatraPDF) is optional and can be configured at the bottom
#   - Existing output files are overwritten (clobbered) by default
#   - JSON config file must have a top-level array of document objects
#   - Each document object requires: "source", "style", and "formats" fields
#   - Optional "active": true/false field to enable/disable document processing
#     (defaults to true if not specified)
#   - Optional "auto-open": list of formats to automatically open after generation
#     (e.g., ["pdf"]). This is the only field name used for auto‑opening.
#   - Documents with "active": false are filtered out before any processing.
#
#===============================================================================

# CODE
#===============================================================================
# TO DO:
# - not look for any style document for HTML documents (generate-md styles them)
# - smart locate of HTML documents for auto-open (as the HTML ends up in a
#   subfolder named after the document)

set -e  # Exit on error
# set -u removed - it causes more problems than it solves with jq and empty arrays

#------------------------------------------------------------------------------
# DEFAULT CONFIGURATION
#------------------------------------------------------------------------------

DEFAULT_CONFIG_FILE="markdown_to_many.json"
CONFIG_FILE=""
VERBOSE=0
AUTO_OPEN_PDF=1
PDF_VIEWER="sumatraPDF.exe"

#------------------------------------------------------------------------------
# HELP FUNCTION
#------------------------------------------------------------------------------

show_help() {
    # Extract the header section (everything before "CODE")
    sed -n '/^# CODE$/q; /^#/p' "$0" | sed 's/^# //; s/^#$//'
    exit 0
}

#------------------------------------------------------------------------------
# UTILITY FUNCTIONS
#------------------------------------------------------------------------------

log_info() {
    echo "INFO: $*"
}

log_error() {
    echo "ERROR: $*" >&2
}

log_verbose() {
    if [[ "$VERBOSE" -eq 1 ]]; then
        echo "VERBOSE: $*"
    fi
}

# Check if a value exists in an array
array_contains() {
    local needle="$1"
    shift
    local array=("$@")
    for item in "${array[@]}"; do
        if [[ "$item" == "$needle" ]]; then
            return 0
        fi
    done
    return 1
}

#------------------------------------------------------------------------------
# CORE RENDERING FUNCTION
#------------------------------------------------------------------------------
# This function assumes the document is active. All inactive documents are
# filtered out by the main loop before calling this function.

render_document() {
    local doc_json="$1"
    local source style formats_json auto_open_json
    local -a formats auto_open_formats
    local basename errors=0
    local temp_odt_needed=0

    source=$(echo "$doc_json" | jq -r '.source // ""')
    style=$(echo "$doc_json" | jq -r '.style // ""')
    formats_json=$(echo "$doc_json" | jq -r '.formats[]? // empty')
    # Only use "auto-open" – no fallback to "auto_open"
    auto_open_json=$(echo "$doc_json" | jq -r '."auto-open"[]? // empty')

    # Convert formats to bash array (handle empty)
    if [[ -n "$formats_json" ]]; then
        readarray -t formats <<< "$formats_json"
    else
        formats=()
    fi

    # Convert auto_open formats to bash array (handle empty)
    if [[ -n "$auto_open_json" ]]; then
        readarray -t auto_open_formats <<< "$auto_open_json"
    else
        auto_open_formats=()
    fi

    basename="${source%.*}"

    # Validate source exists
    if [[ ! -f "$source" ]]; then
        log_error "Source file not found: $source"
        return 1
    fi

    # Validate style exists
    if [[ ! -f "$style" ]]; then
        log_error "Style template not found: $style"
        return 1
    fi

    # Validate at least one format specified
    if [[ ${#formats[@]} -eq 0 ]]; then
        log_error "No formats specified for: $source"
        return 1
    fi

    echo "========================================"
    echo "Processing: $source"
    echo "  Style: $style"
    echo "  Formats: ${formats[*]}"
    echo "  Auto-open formats: ${auto_open_formats[*]:-(none)}"
    echo "----------------------------------------"

    # Check if ODT is needed (either as target or intermediate)
    if array_contains "odt" "${formats[@]}" || \
       array_contains "docx" "${formats[@]}" || \
       array_contains "pdf" "${formats[@]}"; then
        temp_odt_needed=1
    fi

    # Generate ODT if needed
    if [[ $temp_odt_needed -eq 1 ]]; then
        log_info "Generating ODT (intermediate or final)..."
        if ! pandoc -t odt -o "${basename}.odt" --reference-doc="$style" "$source"; then
            log_error "Failed to generate ODT for $source"
            return 1
        fi
        log_verbose "ODT generated: ${basename}.odt"
    fi

    # Generate DOCX if requested
    if array_contains "docx" "${formats[@]}"; then
        log_info "Generating DOCX..."
        if ! soffice.exe --convert-to docx "${basename}.odt" --headless; then
            log_error "Failed to generate DOCX for $source"
            ((errors++))
        else
            log_verbose "DOCX generated: ${basename}.docx"
        fi
    fi

    # Generate PDF if requested
    if array_contains "pdf" "${formats[@]}"; then
        log_info "Generating PDF..."
        if ! soffice.exe --convert-to pdf "${basename}.odt" --headless; then
            log_error "Failed to generate PDF for $source"
            ((errors++))
        else
            log_verbose "PDF generated: ${basename}.pdf"
        fi
    fi

    # Generate HTML if requested
    if array_contains "html" "${formats[@]}"; then
        log_info "Generating HTML..."
        local html_dir="${basename}_HTML"
        mkdir -p "$html_dir"
        if ! generate-md --layout jasonm23-foghorn \
                --input "$source" --output "./$html_dir"; then
            log_error "Failed to generate HTML for $source"
            ((errors++))
        else
            log_verbose "HTML generated in: $html_dir"
        fi
    fi

    # Cleanup: Delete intermediate ODT if not requested as final format
    if [[ -f "${basename}.odt" ]] && ! array_contains "odt" "${formats[@]}"; then
        log_verbose "Removing intermediate ODT file..."
        rm "${basename}.odt"
    fi

    # Auto-open formats if requested
    if [[ ${#auto_open_formats[@]} -gt 0 ]]; then
        for format in "${auto_open_formats[@]}"; do
            local output_file="${basename}.${format}"
            if [[ -f "$output_file" ]]; then
                log_info "Auto-opening: $output_file"
                if command -v start &>/dev/null; then
                    start "$output_file"
                elif command -v xdg-open &>/dev/null; then
                    xdg-open "$output_file"
                elif command -v open &>/dev/null; then
                    open "$output_file"
                else
                    log_error "No suitable command found to open $output_file"
                fi
            else
                log_error "Cannot auto-open: $output_file not found"
            fi
        done
    fi

    # Report results
    if [[ $errors -eq 0 ]]; then
        echo "SUCCESS: Successfully processed: $source"
    else
        echo "WARNING: Completed with $errors errors: $source"
    fi
    echo "========================================"

    return $errors
}

#------------------------------------------------------------------------------
# MAIN EXECUTION
#------------------------------------------------------------------------------

# Parse command line arguments
for arg in "$@"; do
    case "$arg" in
        --help|-h)
            show_help
            ;;
        --verbose|-v)
            VERBOSE=1
            ;;
        *)
            # If it doesn't start with -- or -, treat as config file
            if [[ "$arg" != -* ]]; then
                if [[ -z "$CONFIG_FILE" ]]; then
                    CONFIG_FILE="$arg"
                else
                    log_error "Multiple config files specified: $CONFIG_FILE and $arg"
                    echo "Use --help for usage information"
                    exit 1
                fi
            else
                log_error "Unknown option: $arg"
                echo "Use --help or -h for usage information"
                exit 1
            fi
            ;;
    esac
done

# Set config file to default if not specified
if [[ -z "$CONFIG_FILE" ]]; then
    CONFIG_FILE="$DEFAULT_CONFIG_FILE"
    log_verbose "Using default config file: $CONFIG_FILE"
fi

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    log_error "Config file not found: $CONFIG_FILE"
    echo ""
    echo "Create a JSON config file or specify an existing one."
    echo "Example config:"
    echo '[
        {
            "source": "resume.md",
            "style": "style-template.odt",
            "formats": ["odt", "docx", "pdf", "html"]
        }
    ]'
    echo ""
    echo "Use --help for more information"
    exit 1
fi

# Validate JSON configuration
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    log_error "Invalid JSON in config file: $CONFIG_FILE"
    exit 1
fi

# Count total documents
doc_count=$(jq '. | length' "$CONFIG_FILE")

# Filter to only active documents (active != false, or missing active)
active_docs=$(jq -c '.[] | select(.active != false)' "$CONFIG_FILE")
active_count=$(echo "$active_docs" | grep -c '^' || echo 0)

log_info "Starting document generation..."
log_info "Config file: $CONFIG_FILE"
log_info "Found $doc_count total document(s), $active_count active"
echo ""

# Process only active documents
total_errors=0
if [[ $active_count -gt 0 ]]; then
    while IFS= read -r doc_json; do
        if [[ -n "$doc_json" ]]; then
            if ! render_document "$doc_json"; then
                ((total_errors++))
            fi
        fi
    done <<< "$active_docs"
else
    log_info "No active documents to process."
fi

echo ""
echo "========================================"
if [[ $total_errors -eq 0 ]]; then
    log_info "PASS: All active documents processed successfully!"
else
    log_error "ERROR: Completed with $total_errors document(s) having errors"
fi
echo "========================================"

# Optional: Open PDFs (global fallback, not per-document)
# Set AUTO_OPEN_PDF=0 above to disable this.
if [[ $AUTO_OPEN_PDF -eq 1 ]] && command -v "$PDF_VIEWER" &>/dev/null; then
    # Kill any existing SumatraPDF instances
    if command -v taskkill &>/dev/null; then
        taskkill /f /im "$PDF_VIEWER" 2>/dev/null || true
    fi

    # Open the first PDF found among active documents
    first_pdf=$(echo "$active_docs" | jq -r 'select(.formats[] | contains("pdf")) | .source' | head -1)
    if [[ -n "$first_pdf" ]]; then
        pdf_file="${first_pdf%.*}.pdf"
        if [[ -f "$pdf_file" ]]; then
            log_info "Opening PDF: $pdf_file"
            start "$pdf_file"
        fi
    fi
fi

exit $total_errors
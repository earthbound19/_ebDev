#!/usr/bin/env bash
# backup_or_restore_image_metadata.sh
#
# DESCRIPTION
# Creates or restores a complete metadata backup from an image file.
# 
# For PNG files: Captures ALL text chunks using ExifTool's text output
# format, preserving even invalid data.
#
# For JPEG and other formats: Uses ExifTool's native MIE format.
#
# DEPENDENCIES
# - exiftool
# - Core utilities: mktemp, grep, sed, cut

PROGNAME=$(basename "$0")

print_help() {
    cat <<EOF
Usage: $PROGNAME [OPTIONS]

Options:
  -b, --backup-from-image <file>    Create metadata backup
  -r, --restore-to-image <file>     Restore metadata from backup
  -d, --delete-backup <file>        Delete the backup file(s)
  -c, --check-backup <file>         Check if backup exists and show info
  -h, --help                        Show this help

Examples:
  $PROGNAME --backup-from-image photo.png
  $PROGNAME --restore-to-image photo.png
  $PROGNAME --backup-from-image photo.jpg
EOF
}

check_exiftool() {
    if ! command -v exiftool &> /dev/null; then
        echo "ERROR: exiftool not found in PATH." >&2
        exit 2
    fi
}

get_backup_base() {
    local imagefile="$1"
    local dirname=$(dirname "$imagefile")
    local basename=$(basename "$imagefile" | sed 's/\.[^.]*$//')
    echo "$dirname/${basename}_metabak"
}

verify_image() {
    local imagefile="$1"
    if [ ! -f "$imagefile" ]; then
        echo "ERROR: Image file '$imagefile' does not exist." >&2
        exit 3
    fi
}

# Backup PNG using text format (preserves invalid JSON)
do_backup_png() {
    local imagefile="$1"
    local backup_base="$2"
    local backup_file="${backup_base}.txt"
    
    echo "Backing up PNG: $imagefile"
    
    # Extract all PNG text chunks in human-readable text format
    # This preserves the exact values including invalid JSON
    if exiftool -a -G1 -png:all "$imagefile" > "$backup_file" 2>/dev/null; then
        if [ -s "$backup_file" ]; then
            local size=$(stat -c%s "$backup_file" 2>/dev/null || stat -f%z "$backup_file" 2>/dev/null)
            
            # Count non-structural PNG fields
            local field_count=$(grep "^\[PNG\]" "$backup_file" | grep -v "Image Width\|Image Height\|Bit Depth\|Color Type\|Compression\|Filter\|Interlace" | wc -l)
            
            echo "  Backup saved: $backup_file ($size bytes)"
            echo "  Custom fields backed up: $field_count"
            
            if [ "$field_count" -gt 0 ]; then
                echo "  Fields: $(grep "^\[PNG\]" "$backup_file" | grep -v "Image Width\|Image Height\|Bit Depth\|Color Type\|Compression\|Filter\|Interlace" | sed 's/^\[PNG\] *//' | cut -d: -f1 | tr '\n' ' ')"
            fi
            return 0
        else
            echo "  No metadata found to backup." >&2
            rm -f "$backup_file"
            return 0
        fi
    else
        echo "ERROR: Failed to create backup." >&2
        return 1
    fi
}

# Generate temporary config from text backup
generate_png_config_from_text() {
    local text_backup="$1"
    local temp_config=$(mktemp)
    
    # Extract field names from the text backup
    local fields=$(grep "^\[PNG\]" "$text_backup" | grep -v "Image Width\|Image Height\|Bit Depth\|Color Type\|Compression\|Filter\|Interlace" | sed 's/^\[PNG\] *//' | cut -d: -f1 | sed 's/ *$//')
    
    if [ -z "$fields" ]; then
        rm -f "$temp_config"
        return 1
    fi
    
    # Build config file
    {
        echo '%Image::ExifTool::UserDefined = ('
        echo '    '\''Image::ExifTool::PNG::TextualData'\'' => {'
        
        for field in $fields; do
            echo "        $field => { },"
        done
        
        echo '    },'
        echo ');'
        echo '1;'
    } > "$temp_config"
    
    echo "$temp_config"
}

# Restore PNG from text backup
do_restore_png() {
    local imagefile="$1"
    local backup_base="$2"
    local backup_file="${backup_base}.txt"
    
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" >&2
        return 1
    fi
    
    echo "Restoring PNG: $imagefile"
    
    # Generate config from backup
    local config_file=$(generate_png_config_from_text "$backup_file")
    if [ -z "$config_file" ]; then
        echo "  No custom fields found in backup."
        return 0
    fi
    
    # Parse each field and restore it
    local count=0
    while IFS= read -r line; do
        # Extract field name and value from lines like:
        # [PNG]           Prompt                          : {"1": {...}}
        local field=$(echo "$line" | sed 's/^\[PNG\] *//' | cut -d: -f1 | sed 's/ *$//')
        local value=$(echo "$line" | sed 's/^\[PNG\] *//' | cut -d: -f2- | sed 's/^ //')
        
        if [ -n "$field" ] && [ -n "$value" ]; then
            # Write the tag back using exiftool with config
            if exiftool -config "$config_file" -overwrite_original -"$field"="$value" "$imagefile" 2>/dev/null; then
                echo "  Restored: $field"
                ((count++))
            else
                echo "  WARNING: Failed to restore: $field" >&2
            fi
        fi
    done < <(grep "^\[PNG\]" "$backup_file" | grep -v "Image Width\|Image Height\|Bit Depth\|Color Type\|Compression\|Filter\|Interlace")
    
    rm -f "$config_file"
    echo "  Restored $count field(s)"
}

# Backup non-PNG file
do_backup_standard() {
    local imagefile="$1"
    local backup_file="$2.mie"
    
    echo "Backing up: $imagefile"
    
    exiftool -o "$backup_file" -all:all "$imagefile"
    if [ $? -eq 0 ] && [ -f "$backup_file" ]; then
        local size=$(stat -c%s "$backup_file" 2>/dev/null || stat -f%z "$backup_file" 2>/dev/null)
        echo "  Backup saved: $backup_file ($size bytes)"
        return 0
    else
        echo "ERROR: Failed to create backup." >&2
        return 1
    fi
}

# Restore non-PNG file
do_restore_standard() {
    local imagefile="$1"
    local backup_file="$2.mie"
    
    if [ ! -f "$backup_file" ]; then
        echo "ERROR: Backup file not found: $backup_file" >&2
        return 1
    fi
    
    echo "Restoring: $imagefile"
    
    exiftool -overwrite_original -tagsfromfile "$backup_file" -all:all "$imagefile"
    if [ $? -eq 0 ]; then
        echo "  Metadata restored successfully"
        return 0
    else
        echo "ERROR: Failed to restore metadata." >&2
        return 1
    fi
}

do_backup() {
    local imagefile="$1"
    local backup_base=$(get_backup_base "$imagefile")
    
    verify_image "$imagefile"
    check_exiftool
    
    local ext="${imagefile##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    if [ "$ext" = "png" ]; then
        do_backup_png "$imagefile" "$backup_base"
    else
        do_backup_standard "$imagefile" "$backup_base"
    fi
}

do_restore() {
    local imagefile="$1"
    local backup_base=$(get_backup_base "$imagefile")
    
    verify_image "$imagefile"
    check_exiftool
    
    local ext="${imagefile##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    if [ "$ext" = "png" ]; then
        do_restore_png "$imagefile" "$backup_base"
    else
        do_restore_standard "$imagefile" "$backup_base"
    fi
}

do_delete() {
    local imagefile="$1"
    local backup_base=$(get_backup_base "$imagefile")
    local ext="${imagefile##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    if [ "$ext" = "png" ]; then
        rm -f "${backup_base}.txt"
        echo "Deleted: ${backup_base}.txt"
    else
        rm -f "${backup_base}.mie"
        echo "Deleted: ${backup_base}.mie"
    fi
}

do_check() {
    local imagefile="$1"
    local backup_base=$(get_backup_base "$imagefile")
    local ext="${imagefile##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    if [ "$ext" = "png" ]; then
        local backup_file="${backup_base}.txt"
        if [ -f "$backup_file" ]; then
            local size=$(stat -c%s "$backup_file" 2>/dev/null || stat -f%z "$backup_file" 2>/dev/null)
            local mtime=$(stat -c%y "$backup_file" 2>/dev/null || stat -f%Sm "$backup_file" 2>/dev/null)
            echo "Backup exists: $backup_file"
            echo "  Size: $size bytes"
            echo "  Modified: $mtime"
            
            local field_count=$(grep "^\[PNG\]" "$backup_file" | grep -v "Image Width\|Image Height\|Bit Depth\|Color Type\|Compression\|Filter\|Interlace" | wc -l)
            echo "  Custom fields in backup: $field_count"
            return 0
        fi
    else
        local backup_file="${backup_base}.mie"
        if [ -f "$backup_file" ]; then
            local size=$(stat -c%s "$backup_file" 2>/dev/null || stat -f%z "$backup_file" 2>/dev/null)
            local mtime=$(stat -c%y "$backup_file" 2>/dev/null || stat -f%Sm "$backup_file" 2>/dev/null)
            echo "Backup exists: $backup_file"
            echo "  Size: $size bytes"
            echo "  Modified: $mtime"
            return 0
        fi
    fi
    
    echo "No backup found"
    return 1
}

# Parse arguments
if [ $# -eq 0 ]; then
    print_help
    exit 0
fi

OPTS=$(getopt -o hb:r:d:c: --long help,backup-from-image:,restore-to-image:,delete-backup:,check-backup: -n "$PROGNAME" -- "$@")
if [ $? != 0 ]; then
    echo "Failed parsing options." >&2
    exit 1
fi

eval set -- "$OPTS"

action=""
target=""

while true; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        -b|--backup-from-image)
            action="backup"
            target="$2"
            shift 2
            ;;
        -r|--restore-to-image)
            action="restore"
            target="$2"
            shift 2
            ;;
        -d|--delete-backup)
            action="delete"
            target="$2"
            shift 2
            ;;
        -c|--check-backup)
            action="check"
            target="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error." >&2
            exit 1
            ;;
    esac
done

if [ -z "$target" ]; then
    echo "ERROR: No image file specified." >&2
    exit 1
fi

case "$action" in
    backup) do_backup "$target" ;;
    restore) do_restore "$target" ;;
    delete) do_delete "$target" ;;
    check) do_check "$target" ;;
    *) echo "No valid action specified." >&2; exit 1 ;;
esac
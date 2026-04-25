# DESCRIPTION
# Hai this is a description of the script.

# DEPENDENCIES
# Utilities wut yesh utilities which

# USAGE
# Run with one of the following parameters:
# -b --backup-from-image imagefilename: creates a file with the same basename as imagefilename + _metabak.txt, which is a backup of all metadata found in the image. For example image.jpg was imagefilename would result in image_metabak.txt.
# -r --restore-to-image imagefilename: using the ~metabak.txt file matching imagefilename, restores via overwrite all metadata from the backup. WARNING: this will be a destrutive operation if the metabak.txt file is invalid or corrupted.
# For example to make a metadata backup of image.jpg, run:
#    backup_or_restore_image_metadata.sh --backup-from-image image.jpg
# Or to restor that:
#    backup_or_restore_image_metadata.sh --restore-to-image image.jpg

# NOTES
# Any particular usage notes, details about script behavior, or pitfalls to avoid etc. that may be helpful to the user.


# CODE
function check_space_in_opt_arg {
	if [ "$2" == "" ]; then echo "ERROR: No value or a space (resulting in empty value) passed after optional switch $1. Pass a value without any space after $1 (for example: $1""value""), or if a default is available, don't pass $1, and the default will be used. Exit."; exit 4; fi;
}

# Notify of use of defaults if no parameters passed:
if [ ${#@} == 0 ]; then
    echo "No options provided. Continuing with default settings."
fi

PROGNAME=$(basename $0)

OPTS=`getopt -o hab:c:: --long help,arga,argb:,argc:: -n $PROGNAME -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

ARG_C=default_value

while true; do
  case "$1" in
    -h | --help ) print_halp; exit 0 ;;
    -a | --arga ) ARG_A=flag_a_set; shift ;;
    -b | --argb ) ARG_B=$2; shift; shift ;;
    -c | --argc ) check_space_in_opt_arg $1 $2; ARG_C=$2; shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

# Throw error and exit if mandatory argument(s) missing:
if [ ! $ARG_B ]; then echo "No argument b --argb (explanation of argument) passed to script. Exit."; exit 1; fi
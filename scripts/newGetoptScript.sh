# DESCRIPTION
# Creates a new randomly named script with a getopt preferred template for argument parsing, and opens it in the defualt editor (perhaps erroneously assuming you have .sh files set to open in a text editor).

# USAGE
# Run without any parameters:
#    newGetoptScript.sh
# For example:
#    scriptFileName.sh parameterOne

# CODE
fullPathToThisScript=$(getFullPathToFile.sh newGetoptScript.sh)
rndString=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 9)
newScriptName=new_script_"$rndString".sh
tail -n +17 $fullPathToThisScript > $newScriptName
start $newScriptName
# EVERYTHING AFTER THIS LINE IS META! IT WILL BE WRITTEN by the script to a new randomly named script, but everything on this line and above will not!
# DESCRIPTION
# omigoshomigoshomigoshomigoshomigoshomigoshomigoshomigosh

# USAGE
# Run with these parameters:
# - $1 (describe parameter)
# For example:
#    scriptFileName.sh parameterOne


# CODE
# Adapted re:
#    http://www.bahmanm.com/blogs/command-line-options-how-to-parse-in-bash-using-getopt
#    https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/
#    https://gist.github.com/dyndna/3b8e7c3e693cdd8b4c6af13abb0523b1

function print_halp {
	echo u need halp k read doc. here is doc. bai. wait what programmer no wrote doc? sad.
}

# Notify of use of defaults if no parameters passed:
if [ ${#@} == 0 ]; then
    echo "No options provided. Continuing with default settings."
fi

# NOTES:
# In the following options string:
# - "a" and "arga" (different names for the same option) have no arguments, acting as sort of a flag.
# - "b" and "argb" (different names for the same option) have required arguments.
# - "c" and "argc" (") have optional arguments with default values.
# Because:
# - no colon after a parameter means no parameter is taken for it (it's functionally a flag)
# - one colon means it takes one required parameter
# - two colons means it can take one optional parameter.
# Also, optional parameters must have no space between the option letter and parameter; e.g. if an optional parameter `-a` is used than it must be passed as `-aOption`!
# Also, see MORE NOTES in the case switch below.
# Also, from a script I saw it can be useful to get the name of the script:
PROGNAME=$(basename $0)
# -- and then use that with the --name argument of getopts:
#    ARGS=`getopt -q --name "$PROGNAME" --long help,output:,verbose --options ho:v -- "$@"`
OPTS=`getopt -o hab:c:: --long help,arga,argb:,argc:: -n $PROGNAME -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

# SET ANY DEFAULTS that would be overriden by optional arguments here:
ARG_C=default_value
# MORE NOTES: cases that operate on 2 words, for example '-b foo', should use the shift statement twice, to remove both used words from the option list, while options that only operate on one word, for example '-a', should use the shift statement once, to remove only the one used word from the option list.
while true; do
  case "$1" in
    -h | --help ) print_halp; exit 0 ;;
    -a | --arga ) ARG_A=flag_a_set; shift ;;
    -b | --argb ) ARG_B=$2; shift; shift ;;
    -c | --argc ) if [ "$2" == "" ]; then echo "WARNING: No value or a space (resulting in empty value) after optional parameter -c --argc. Pass a value without any space after -c (for example: -cvalue), or else don't pass -c and a default value will be used for it. Exit."; exit 4; fi; ARG_C=$2; shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

# Throw error and exit if mandatory argument(s) missing:
if [ ! $ARG_B ]; then echo "No argument b --argb (explanation of argument) passed to script. Exit."; exit 1; fi

echo ARG_A is $ARG_A
echo ARG_B is $ARG_B
echo ARG_C is $ARG_C

# print positional args
# args=("$@")
# echo
# echo positional arguments\#: [${#args[@]}]
# echo @: [${args[@]}]
# for ((i=0; i<${#args[@]}; i++)); do
    # echo ${args[i]};
# done
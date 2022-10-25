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

# print help and exit if no paramers passed:
if [ ${#@} == 0 ]; then print_halp; exit 1; fi

# IN THE FOLLOWING options string:
# - "a" and "arga" (different names for the same option) have no arguments, acting as sort of a flag.
# - "b" and "argb" (different names for the same option) have required arguments.
# - "c" and "argc" (") have optional arguments with default values.
# Because:
# - no colon after a parameter means no parameter is taken for it (it's functionally a flag)
# - one colon means it takes one required parameter
# - two colons means it can take on optional parameter.
# ALSO NOTE: optional parameters must no space between the option letter and parameter; e.g. if an optional parameter `-a` is used than it must be passed as `-aOption`!
# ALSO ALSO NOTE: from a script I saw it can be useful to get the name of the script:
PROGNAME=$(basename $0)
# -- and then use that with the --name argument of getopts:
#    ARGS=`getopt -q --name "$PROGNAME" --long help,output:,verbose --options ho:v -- "$@"`
OPTS=`getopt -o hab:c:: --long help,arga,argb:,argc:: -n $PROGNAME -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

# SET ANY DEFAULTS that would be overriden by optional arguments here:
ARG_C=default_value
while true; do
  case "$1" in
    -h | --help ) print_halp; exit 0 ;;
    -a | --arga ) ARG_A=flag_a_set; shift ;;
    -b | --argb ) ARG_B=$2; shift; shift ;;
    -c | --argc ) ARG_C=$2; shift; shift ;;
    -- ) echo "Unknown script input encountered: $1 $2. Exit."; exit 1 ;;
    * ) break ;;
  esac
done

# Throw error and exit if mandatory argument(s) missing:
if [ ! $ARG_B ]; then echo "No argument b --argb (explaination of argument) passed to script. Exit."; exit 1; fi

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
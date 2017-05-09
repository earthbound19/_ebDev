# re http://stackoverflow.com/a/29754866/1397555 :
# Usage: 
 # getopt optstring parameters
 # getopt [options] [--] optstring parameters
 # getopt [options] -o|--options optstring [options] [--] parameters

# Options:
 # -a, --alternative            Allow long options starting with single -
 # -h, --help                   This small usage guide
 # -l, --longoptions <longopts> Long options to be recognized
 # -n, --name <progname>        The name under which errors are reported
 # -o, --options <optstring>    Short options to be recognized
 # -q, --quiet                  Disable error reporting by getopt(3)
 # -Q, --quiet-output           No normal output
 # -s, --shell <shell>          Set shell quoting conventions
 # -T, --test                   Test for getopt(1) version
 # -u, --unquoted               Do not quote the output
 # -V, --version                Output version information

# NOTE; this script setup takes an unlabeled paramater as $1, and decides it means the output file.

 getopt --test > /dev/null
if [[ $? != 4 ]]; then
    echo "I’m sorry, `getopt --test` failed in this environment."
    exit 1
fi

SHORT=dfo:v
LONG=debug,force,output:,verbose

# -temporarily store output to be able to check for errors
# -activate advanced mode getopt quoting e.g. via “--options”
# -pass arguments only via   -- "$@"   to separate them correctly
PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
if [[ $? != 0 ]]; then
    # e.g. $? == 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# use eval with "$PARSED" to properly handle the quoting
eval set -- "$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -d|--debug)
            d=y
            shift
            ;;
        -f|--force)
            f=y
            shift
            ;;
        -v|--verbose)
            v=y
            shift
            ;;
        -o|--output)
            outFile="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

# handle non-option arguments
if [[ $# != 1 ]]; then
    echo "$0: A single input file is required."
    exit 4
fi

echo "verbose: $v, force: $f, debug: $d, in: $1, out: $outFile"
 
 # Another option: http://unix.stackexchange.com/a/20977

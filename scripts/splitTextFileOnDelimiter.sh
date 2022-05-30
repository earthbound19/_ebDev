# DESCRIPTION
# Splits file $1 (input file name) on delimiter $2 (arbitrary text string) into N files (count of delimiter $2) with prefix $3 (arbitrary filename-friendly string) and incrementing numbers (starting at 1) for each resulting file name. Leaves original file $1 intact.

# USAGE
# Run with these parameters:
# - $1 input file name. May be surrounded by quote marks if necessary.
# - $2 arbitrary text string to find and split files on (split will be everything between each delimiter). May be surrounded by quote marks if necessary.
# - $3 prefix of filenames for split results. Terminal-friendly characters only recommended (e.g. no spaces or unusual characters).
# Example that will split the source text file entropy_source_deleted_dev_emails_1.txt into files delimited by the text "From:", into files with the word "delDevMail_entropySource_" at the start of the file name:
#    splitTextFileOnDelimiter.sh entropy_source_deleted_dev_emails_1.txt "From:" delDevMail_entropySource_
# NOTE
# If you run into speed problems or need to operate on huge data, try: https://stromberg.dnsalias.org/~strombrg/context-split.html -- re: https://stackoverflow.com/a/11315931


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (input file name) passed to script. Exit."; exit 1; else inputFileName=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (text delimiter string) passed to script. Exit."; exit 2; else delimiterString=$2; fi
if [ ! "$3" ]; then printf "\nNo parameter \$3 (output filenames prefix) passed to script. Exit."; exit 3; else outputFileNamesPrefix=$3; fi

# get count of regex matches of $delimiterString in $inputFileName..
matchCount=$(grep -E -o "$delimiterString" $inputFileName | wc -l)
# ..and use it to figure out how many digits to pad output file numbers to:
digits=${#matchCount}

# Adapted from: https://stackoverflow.com/a/11314918
csplit --quiet --prefix=$outputFileNamesPrefix --suffix-format="%0""$digits""d.txt" $inputFileName "/$delimiterString/+1" "{*}"
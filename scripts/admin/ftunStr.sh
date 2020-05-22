# DESCRIPTION
# Takes a string parameter $1 and echoes a terminal-friendly string
# (e.g. for file names); Fixes Terminal Un-friendly Strings.

# USAGE
# Invoke this script with one parameter surrounded either in double
# or singl quotes: e.g.
# ./ftunStr.sh "Mountain@Landscape over] Downtown'' Provo UT"
#  OR
# ./ftunStr.sh 'Mountain@Landscape over]"" Downtown Provo UT'
# To make use of the echoed result in another script by
#  storing it in a variable, surround the call with backticks
#  and assign it to a variable:
# terminalFriendlyString=`./ftunStr.sh "Mountai'n Landscape#$ over Downtown Provo UT"`


# CODE
echo $1 | tr \"\'\=\@\`~\!#$%^\&\(\)+[{]}\;\ , _
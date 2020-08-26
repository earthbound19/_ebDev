# DESCRIPTION
# Takes a string parameter $1 and echoes a terminal-friendly string (for example for file names); Fixes Terminal Un-friendly Strings.

# USAGE
# Run this script with one parameter surrounded either in double or single quotes. For example:
#    ftunStr.sh "Mountain@Landscape over] Downtown'' Provo UT"
#  OR
#    ftunStr.sh 'Mountain@Landscape over]"" Downtown Provo UT'
# To make use of the echoed result in another script by storing it in a variable, use command substitution:
#    terminalFriendlyString=$(./ftunStr.sh "Mountai'n Landscape#$ over Downtown Provo UT")


# CODE
echo $1 | tr \"\'\=\@\`~\!#$%^\&\(\)+[{]}\;\ , _
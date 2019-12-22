# DESCRIPTION
# Repeatedly invokes getNshadesOfColorCIECAM02.py for every color in a .hexplt file $1, with default settings and -n = 13 (hack command to change; not making it a CLI option in this script)

# USAGE
# getNshadesOfColors.sh inputPalette.hexplt

whereScriptIs=`which getNshadesOfColorCAM16-colour-science.py`
arr=$(<$1)

for element in ${arr[@]}
do
  command="python $whereScriptIs -c $element -n 13"
  $command
  # echo \'$element\'
done
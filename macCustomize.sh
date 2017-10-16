# npm packages I regularly use:
# PREREQUISITE; npm:
while read element
  echo item is $element . .
done < ./npmPackages.txt

# command for Atom open-terminal-here package on Mac (requires ttab to be installed) which allows opening any path to terminal by shortcut:
# ttab && cd "$PWD"
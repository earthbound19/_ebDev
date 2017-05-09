# ADDS THE CURRENT path to your terminal profile temporarily (you will lose the path on terminal restart). NOTE that after this has been done for the path which contains this script, since this script is then in the path, the same can be done by calling this script from any other path--that "any other path" will then also be temporarily in your path.

thisDir=`pwd`
# echo thisDir value is\: $thisDir

PATH=$thisDir:\$PATH
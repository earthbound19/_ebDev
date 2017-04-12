# ADDS THE CURRENT path to your ~./bash_profile. Must be run with admin priveleges (e.g. sudo on mac or various linux). NOTE that after this has been done for the path which containst this script, since this script is then in the path, the same can be done by calling this script (from any other path).

thisDir=`pwd`
# echo thisDir value is\: $thisDir

# IF THERE IS no .bash_profile in the home dir, create one:
if [ ! -a ~/.bash_profile ]
then
  touch ~/.bash_profile
fi

echo export PATH=$thisDir:\$PATH >> ~/.bash_profile
# NOTE that the following may do no good; you may have to invoke that command separately after running this script:
source ~/.bash_profile

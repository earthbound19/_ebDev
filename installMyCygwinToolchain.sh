# Copy the cygwin installer to this directory before executing this script. Comment out the line for the cygwin installer version you don't want to use.
installParams="-q -P perl -P gcc-g++ -P make -P diffutils -P libmpfr-devel -P libgmp-devel -P libmpc-devel -q -P bc -P xxd"

./Cygwin_setup-x86.exe $installParams
# ./Cygwin_setup-x86_64.exe $installParams

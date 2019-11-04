# NOTE: to install xxd, see installCygwinXXD.sh

# Run this script from the directory with the installer, with this script in your PATH, or copy the cygwin installer to this directory before executing this script. Comment out the line for the cygwin installer version you don't want to use.
installParams="-q -P perl -P gcc-g++ -P make -P diffutils -P libmpfr-devel -P libgmp-devel -P libmpc-devel -P bc"

# ./Cygwin_setup-x86.exe $installParams
./Cygwin_setup-x86_64.exe $installParams

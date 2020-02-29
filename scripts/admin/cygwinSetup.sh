# DESCRIPTION
# Commands to install wanted tools and custom configuration for a Cygwin install.

# USAGE
# Run this script from the directory with the installer, with this script
# and the other files it needs (CYGWIN_fstab, my.minttyrc.settings.txt) in
# your PATH, or copy the cygwin installer to this directory before executing
# this script. Comment out the line for the cygwin installer version you don't
#want to use.


# CODE
installParams="-q -P perl -P gcc-g++ -P make -P diffutils -P libmpfr-devel -P libgmp-devel -P libmpc-devel -P bc -P lynx -P chere"

# ./Cygwin_setup-x86.exe $installParams
./Cygwin_setup-x86_64.exe $installParams

lynx -source rawgit.com/transcode-open/apt-cyg/master/apt-cyg > apt-cyg
dos2unix apt-cyg
install apt-cyg /bin

username=`whoami`
echo "Username is $username. OVERWRITING configuration of /home/$username/.minttyrc with my.minttyrc.settings.txt. Continue?"
echo "!============================================================"
read -p "DO YOU WISH TO CONTINUE running this script? : y/n" CONDITION;
if [ "$CONDITION" == "y" ]; then
		echo Ok! Attempting overwrite . . .
		cat ./my.minttyrc.settings.txt > /home/$username/.minttyrc
		echo Done. Exit and restart the shell after all of the remaining commands complete, to see if the configuration \"stuck.\"
	else
		echo D\'oh!; exit;
fi

# Overwrites fstab that comes with bad evil pointlessly restrictive
# (for my purposes) permissions defaults with defaults we actually want;
# RE: https://superuser.com/a/392598/130772 :
cp ./CYGWIN_fstab /etc/fstab
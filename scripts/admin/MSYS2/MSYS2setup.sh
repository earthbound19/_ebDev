# DESCRIPTION
# Installs desired msys2 packages and does other customization setup.

# USAGE
# Run this script without any parameters:
#    MSYS2setup.sh
# NOTES
# This overwrites .ini and bash profile files with settings from the same directory this script is kept in. Those settings include:
# - inheriting SYSTEM environment variables on terminal launch
# - terminal font, color, and mouse interaction preferences
# - installing registry keys that provide right-click "MSYS2 Bash here" (also for compiler/dev environment) menus
# - if you don't get the mentioned right-click menu after running this, try right-clicking the .reg file to install it and then click "Merge," or try running this script again from a terminal launched with administrator privileges.


# CODE
# TO DO:
# - activate native symlinks via uncomment line in msys2_shell.cmd?
echo "u go kaboomy haha now you dead moldy voldy -Snep"

MSYS2_packages=" \
vim \
Perl \
p7zip \
gcc \
make \
diffutils \
bc"

# packages I may in the future use:
# mingw-w64-x86_64-libc++ \
# mingw-w64-x86_64-boost \
# mingw-w64-x86_64-gcc \

for element in ${MSYS2_packages[@]}
do
	# UNINSTALL option:
	# pacman -R --noconfirm $element
	pacman -S --noconfirm $element
done

# copy profile customizations into MSYS2 user root:
cp ./.bashrc ~
cp ./.minttyrc ~
# install right-click "~ Bash here" registry settings:
reg import install_MSYS2_right_click_menu.reg
# get MSYS2 install root path; sed expression that captures MSYS2 install location, PERHAPS ERRONEOUSLY assuming that it's installed in a root dir only one folder in; hmm . . . this is DEPRECATED: `echo "$WD" | sed 's/\(^[^\]*\)\\\([^\]*\).*/\1\\\2\\/g'` . . . assuming instead that whatever is above /usr/bin is the base install path:
nixyPathConversionFromA_sed_expressionThatMakesMeCryInFrench=`echo $WD | sed 's/\\\\/\//g'`
ohThisIsKlugy=`dirname $nixyPathConversionFromA_sed_expressionThatMakesMeCryInFrench`
MSYS2installDir=`dirname $ohThisIsKlugy`
cp msys2_shell.cmd $MSYS2installDir
cp msys2.ini $MSYS2installDir
cp mingw64.ini $MSYS2installDir
cp mingw32.ini $MSYS2installDir

echo "DONE. If MSYS2 is not up to date, you may wish to run these commands, then exit the MSYS2 terminal, and run them again:"
echo "pacman -Syy"
echo "pacman -Suu"


# DEVELOPER NOTES
# Some reference on that:
# h/t: https://www.rjh.io/blog/20190722-msys2_setup/
# The right-click menu provided via my fork of a tool: https://github.com/earthbound19/msys2-mingw-shortcut-menus
#
# In my Cygwin setup and I don't know why:
# libmpfr-devel, libgmp-devel, lynx
# gcc-g++, but I hope just gcc here is equivalent
# chere
#
# vim is in this list because it includes xxd. But, um . . also vim? :|
#
# I hoped this would include iostream.h; nope:
# mingw-w64-x86_64-gcc
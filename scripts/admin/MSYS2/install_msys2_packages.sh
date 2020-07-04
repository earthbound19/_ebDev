# DESCRIPTION
# Installs desired msys2 packages.

# USAGE
# Run this script.
# NOTES
# To inherit the windows PATH in the MSYS2 terminal, uncomment lines in the MSYS2 launch batch scripts (such as msys2_shell.cmd) and/or .ini files which set this value:
#
# MSYS2_PATH_TYPE=inherit
#
# h/t: https://www.rjh.io/blog/20190722-msys2_setup/
#
# To get a right-click menu to open any folder in the MSYS2 terminal, double-click the installer .reg file in this folder, which was created via my fork of a tool: https://github.com/earthbound19/msys2-mingw-shortcut-menus

# TO DO
# Auto-mod (on install) the files mentioned in MSYS2_notes.txt
# so that MSYS2 inherits the system PATH.


# CODE

echo "u go kaboomy haha now you dead moldy voldy -Snep"

# In my cygwin setup and I don't know why:
# libmpfr-devel, libgmp-devel, lynx
# gcc-g++, but I hope just gcc here is equivalent
# chere

# vim is in this list because it includes xxd. But, um . . also vim? :|

MSYS2_packages=" \
vim \
perl \
gcc \
make \
diffutils \
mingw-w64-x86_64-libc++ \
mingw-w64-x86_64-boost \
mingw-w64-x86_64-gcc \
bc"

# hoped this would include iostream.h; nope:
# mingw-w64-x86_64-gcc

for element in ${MSYS2_packages[@]}
do
	pacman -S --noconfirm $element
done

echo "DONE. If MSYS2 is not up to date, you may wish to run these commands, then exit the MSYS2 terminal, and run them again:"
echo "pacman -Syy"
echo "pacman -Suu"

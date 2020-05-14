# DESCRIPTION
# Installs desired msys2 packages.


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
bc"

for element in ${MSYS2_packages[@]}
do
	pacman -S --noconfirm $element
done

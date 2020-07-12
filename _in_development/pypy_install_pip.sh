# DESCRIPTION
# Installed pip with pypy3, so that you can install other packages (for use with pypy3) via pip.
# re: https://stackoverflow.com/a/44737687/1397555
# From the directory with pypy3 in it, run (can alter it withuot the ./ if you put pypy3 in your PATH) :

./pypy3 -m ensurepip
./pypy3 -m pip install --upgrade pip
#  pypy3 -m pip install whatever_package_name
#  pypy3 -m pip install whatever_package_name
#  pypy3 -m pip install whatever_package_name
# etc. . . .
# DESCRIPTION
# Supposedly builds and installs python with frameworks and tcl-tk (for idle) enabled, on Mac OS.
# After this you can run python -m idlelib & (pyenv-idle.py) to run python IDLE.

# SEE ALSO? : https://hackernoon.com/reaching-python-development-nirvana-bb5692adf30c

# IF YOU RUN INTO TROUBLE, uncomment any/many these code lines before the last:
# brew uninstall pyenv && rm -rf ~/.pyenv
# brew reinstall readline xz zlib
# 
# # per brew warnings for the above:
# export LDFLAGS="-L/usr/local/opt/readline/lib"
# export CPPFLAGS="-I/usr/local/opt/readline/include"
# export PKG_CONFIG_PATH="/usr/local/opt/readline/lib/pkgconfig"
# export LDFLAGS="-L/usr/local/opt/zlib/lib"
# export CPPFLAGS="-I/usr/local/opt/zlib/include"
# export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"
# 
# export LDFLAGS="-L/usr/local/opt/tcl-tk/lib"
# export CPPFLAGS="-I/usr/local/opt/tcl-tk/include"
# export PATH=$PATH:/usr/local/opt/tcl-tk/bin
# 
# export LDFLAGS="${LDFLAGS} -L/usr/local/opt/zlib/lib"
# export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/zlib/include"
# export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} /usr/local/opt/zlib/lib/pkgconfig"
# 
# # AND/OR? ; re:
# # https://gist.githubusercontent.com/pimterry/f3a443bf43e835414b5f05c56b1fcbcd/raw/638c825c2c16a529e4586d4329d111f35fcf7d01/pyenv-install-python-on-osx-with-homebrew.sh re https://medium.com/@pimterry/setting-up-pyenv-on-os-x-with-homebrew-56c7541fd331
# CFLAGS="-I$(brew --prefix readline)/include -I$(brew --prefix openssl)/include -I$(xcrun --show-sdk-path)/usr/include" \
# LDFLAGS="-L$(brew --prefix readline)/lib -L$(brew --prefix openssl)/lib" \
# PYTHON_CONFIGURE_OPTS=--enable-unicode=ucs2 \
# 
# brew install pyenv
# 
# # env PYTHON_CONFIGURE_OPTS="--enable-framework --with-tcl-tk" pyenv install 3.5.3 --verbose
# env PYTHON_CONFIGURE_OPTS="--enable-framework --with-tcl-tk" pyenv install 3.8.0 --verbose
# 
# 
# # FOR IDE INTEGRATION, see: https://towardsdatascience.com/managing-virtual-environment-with-pyenv-ae6f3fb835f8


brew uninstall pyenv && rm -rf ~/.pyenv
brew uninstall tcl-tk

# brew reinstall readline xz zlib
brew install pyenv
brew install tcl-tk

# echo "READ THE COMMENT labeled THREE IN pyenvFrameworkInstallMac.sh; follow those instructions."

# THREE:
# To get tcl-tk 8.6 to work with the pyenv install of python, I found:
# /usr/local/Cellar/pyenv/1.2.15/plugins/python-build/bin/python-build
# (you must find the actual pyenv version string to find the dir!)
# and replaced the following:
# $CONFIGURE_OPTS ${!PACKAGE_CONFIGURE_OPTS} "${!PACKAGE_CONFIGURE_OPTS_ARRAY}" || return 1
# with:
# $CONFIGURE_OPTS --with-tcltk-includes='-I/usr/local/opt/tcl-tk/include' --with-tcltk-libs='-L/usr/local/opt/tcl-tk/lib -ltcl8.6 -ltk8.6' ${!PACKAGE_CONFIGURE_OPTS} "${!PACKAGE_CONFIGURE_OPTS_ARRAY}" || return 1

# OR? ADAPTING THAT:

env PYTHON_CONFIGURE_OPTS="--enable-unicode=ucs4 --enable-framework --with-tcltk-includes='-I/usr/local/opt/tcl-tk/include' --with-tcltk-libs='-L/usr/local/opt/tcl-tk/lib -ltcl8.6 -ltk8.6'" pyenv install 3.8.0 --verbose

pyenv global 3.8.0
#
# --and check the result with:
pyenv version
#
# -- and upgrade pip:
pip install --upgrade pip
#
# -- test tkinter with:
python -m tkinter -c 'tkinter._test()'
#
# -- test idle with:
# idle
#
# -- OR: use the command in pyenv-idle.py? :
python -m idlelib &
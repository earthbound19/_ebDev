# DESCRIPTION
# Supposedly builds and installs python with frameworks and tcl-tk (for idle) enabled, on Mac OS.
# After this you can run python -m idlelib & (pyenv-idle.py) to run python IDLE.

# IF YOU RUN INTO TROUBLE, uncomment any/many these code lines before the last:
# brew uninstall pyenv && rm -rf ~/.pyenv
# brew install readline xz zlib

export LDFLAGS="-L/usr/local/opt/tcl-tk/lib"
export CPPFLAGS="-I/usr/local/opt/tcl-tk/include"
export PATH=$PATH:/usr/local/opt/tcl-tk/bin

export LDFLAGS="${LDFLAGS} -L/usr/local/opt/zlib/lib"
export CPPFLAGS="${CPPFLAGS} -I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} /usr/local/opt/zlib/lib/pkgconfig"

# brew install pyenv

env PYTHON_CONFIGURE_OPTS="--enable-framework --with-tcl-tk" pyenv install 3.5.3 --verbose
# OR e.g. for other python versions:
# env PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install 3.8.0 --verbose






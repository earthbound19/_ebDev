# DESCRIPTION
# Installs all the brew packages I commonly use.

# USAGE
# Run without any parameters:
#    installUsedBrewPackages.sh
# NOTES
# To get a list of all homebrew installed packages to back up here, run:
#    brew list -1 > installedBrewPackages.txt
# Also, to uninstall every brew package but keep brew, run; re: https://github.com/Homebrew/legacy-homebrew/issues/48792
#    brew list -1 | xargs brew rm
# NOTES
# It's my preference to put executables from the installed path of coreutils _before_ Mac's built-in tools of the same name, re: https://formulae.brew.sh/formula/coreutils -- which I accomplish in macDevSetup.sh via a printf command appending the following to ~/.bash_profile:
#
#    PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
#
# And:
#
#    PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"


# CODE
# TO DO: re-check which of these correspond to functionality I want in my cross-platform _ebDev scripts:
brewPackages=" \
gnu-sed \
coreutils \
ffmpeg \
pandoc \
automake \
autoconf \
libyaml \
readline \
libxslt \
unixodbc \
GraphicsMagick \
pyenv \
findutils \
rename \
exiftool \
jq \
basictex \
dcraw \
blink1 \
tcl-tk \
nkf \
p7zip \
openimageio"

# See pyenvFrameworkInstallMac.sh.

# gnupg \
# yarn \
# argtable \
# boost \
# cmake \
# cocoapods \
# cryptopp \
# freetype \
# gdbm \
# ghostscript \
# gmp \
# gperftools \
# hiredis \
# icu4c \
# jpeg \
# jsoncpp \
# lame \
# leveldb \
# libjson-rpc-cpp \
# libmicrohttpd \
# libpng \
# libssh2 \
# libtiff \
# little-cms2 \
# miniupnpc \
# pcre2 \
# Perl \
# phantomjs \
# pkg-config \
# ruby \
# rust \
# snappy \
# sqlite \
# x264 \
# xvid \
# xz \
# llvm \


for element in ${brewPackages[@]}
do
  brew uninstall $element
done

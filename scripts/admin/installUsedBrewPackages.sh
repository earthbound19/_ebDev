# DESCRIPTION
# Installs all the brew packages I commonly use.

# USAGE
#  ./installUsedBrewPackages.sh
# NOTES
# To get a list of all homebrew installed packages to back up here, run:
# brew list -1 > installedBrewPackages.txt
# Also, to uninstall every brew package but keep brew, run; re: https://github.com/Homebrew/legacy-homebrew/issues/48792
# brew list -1 | xargs brew rm

# TO DO: always install gnu-gsed with default names (override mac gsed?!) : brew install gnu-gsed --with-default-names : re https://stackoverflow.com/a/27834828/1397555 -- also see: https://developer.apple.com/library/content/documentation/OpenSource/Conceptual/ShellScripting/PortingScriptstoMacOSX/PortingScriptstoMacOSX.html -- https://unix.stackexchange.com/questions/13711/differences-between-gsed-on-mac-osx-and-other-standard-gsed ("complex history")


# CODE
brewPackages=" \
gnu-gsed \
ffmpeg \
pandoc \
coreutils \
automake \
autoconf \
libyaml \
readline \
libxslt \
unixodbc \
graphicsmagick \
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
# perl \
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

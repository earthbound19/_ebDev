# DESCRIPTION
# Installs all the brew packages I commonly use.

# USAGE
#  ./installUsedBrewPackages.sh
# NOTES
# To get a list of all homebrew installed packages to back up here, run:
# brew list -1 > installedBrewPackages.txt
# Also, to uninstall every brew package but keep brew, run; re: https://github.com/Homebrew/legacy-homebrew/issues/48792
# brew list -1 | xargs brew rm

# TO DO: always install gnu-gsed with default names (override mac sed?!) : https://stackoverflow.com/questions/5694228/sed-in-place-flag-that-works-both-on-mac-bsd-and-linux/27834828#comment96137537_27834828  https://developer.apple.com/library/content/documentation/OpenSource/Conceptual/ShellScripting/PortingScriptstoMacOSX/PortingScriptstoMacOSX.html -- https://unix.stackexchange.com/questions/13711/differences-between-sed-on-mac-osx-and-other-standard-sed ("complex history")


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

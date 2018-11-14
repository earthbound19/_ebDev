# NOTES
# To get a list of all homebrew installed packages to back up here, run:
# brew list -1 > installedBrewPackages.txt
# Also, to uninstall every brew package but keep brew, run; re: https://github.com/Homebrew/legacy-homebrew/issues/48792
# brew list -1 | xargs brew rm

# TO DO: always install gnu-sed with default names (override mac sed?!) : brew install gnu-sed --with-default-names : re https://stackoverflow.com/a/27834828/1397555 -- also see: https://developer.apple.com/library/content/documentation/OpenSource/Conceptual/ShellScripting/PortingScriptstoMacOSX/PortingScriptstoMacOSX.html -- https://unix.stackexchange.com/questions/13711/differences-between-sed-on-mac-osx-and-other-standard-sed ("complex history")

brewPackages=" \
gnu-sed \
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
gnupg"

# yarn \
# argtable \
# boost \
# cmake \
# cocoapods \
# cryptopp \
# findutils \
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

for element in ${brewPackages[@]}
do
  brew install $element
done

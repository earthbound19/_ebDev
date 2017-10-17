# NOTES
# To get a list of all homebrew installed packages to back up here, run:
# brew list -1 > installedBrewPackages.txt
# Also, to uninstall every brew package but keep brew, run; re: https://github.com/Homebrew/legacy-homebrew/issues/48792
# brew list -1 | xargs brew rm

brewPackages=" \
automake \
libxslt \
unixodbc \
argtable \
autoconf \
boost \
cmake \
cocoapods \
coreutils \
cryptopp \
ffmpeg \
fish \
freetype \
gdbm \
ghostscript \
git \
gmp \
gnu-sed \
gperftools \
graphicsmagick \
hiredis \
icu4c \
jpeg \
jsoncpp \
lame \
leveldb \
libjson-rpc-cpp \
libmicrohttpd \
libpng \
libssh2 \
libtiff \
libtool \
libyaml \
little-cms2 \
miniupnpc \
openssl \
pandoc \
pcre2 \
perl \
phantomjs \
pkg-config \
pyenv \
python3 \
qt \
readline \
ruby \
rust \
snappy \
sqlite \
x264 \
xvid \
xz \
yarn"

for element in ${brewPackages[@]}
do
  brew install $element
done

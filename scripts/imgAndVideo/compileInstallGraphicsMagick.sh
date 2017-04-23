# OR DON'T, and instead use macports to compile/install it.

# THANKS TO: http://mac-dev-env.patrickbougie.com/graphicsmagick/
# ! : http://mac-dev-env.patrickbougie.com/

# NOTE: ommited the following compiler flag lines from the ./configure section as they failed on my system:
# LDFLAGS="-L/usr/local/libjpeg/lib -L/usr/local/libpng/lib -L/usr/local/libtiff/lib" \
# CPPFLAGS="-I/usr/local/libjpeg/include -I/usr/local/libpng/include -I/usr/local/libtiff/include" \

# cd /usr/local/src
curl --remote-name --location http://download.sourceforge.net/graphicsmagick/GraphicsMagick-1.3.25.tar.gz
tar -xzvf GraphicsMagick-1.3.25.tar.gz
cd GraphicsMagick-1.3.25
./configure CC=clang --prefix=/usr/local/mac-dev-env/graphicsmagick-1.3.25
make
sudo make install
sudo ln -s mac-dev-env/graphicsmagick-1.3.25 /usr/local/graphicsmagick
echo 'export PATH=/usr/local/graphicsmagick/bin:$PATH' >> ~/.bash_profile
source ~/.bash_profile
echo ~=~=~=~=~=~=~ VERIFYING INSTALL ~=~=~=~=~=~=~
echo ~=~=~=~=~=~=~ if the below shows no errors, you're good.
gm version
gm convert -list formats

cd
# NOTES
# I imagine more image formats could be supported by including libraries for which the following output said "no" to me:
#
#   BZIP                     yes
#   DPS                      no
#   FlashPix                 no
#   FreeType                 yes
#   Ghostscript (Library)    no
#   JBIG                     no
#   JPEG-2000                no
#   JPEG                     yes
#   Little CMS               no
#   Loadable Modules         no
#   OpenMP                   no
#   PNG                      yes
#   TIFF                     yes
#   TRIO                     no
#   UMEM                     no
#   WebP                     no
#   WMF                      no
#   X11                      yes
#   XML                      yes
#   ZLIB                     yes

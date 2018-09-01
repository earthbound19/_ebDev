# DESCRIPTION
# Builds and installs python 3.7.0rc1 with frameworks enabled, on Mac OSX. I want pyinstall to see if a build executable from colorGrowth.py runs more efficiently than that script running against the Python interpreter. At this writing, pyinstall apparently works with Python up to v 3.5.2, so using that:

sudo env PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install 3.5.2 --verbose


# THE FOLLOWING FAILED, re: https://github.com/pyenv/pyenv/issues/99#issuecomment-34971668 to fix pyinstall not working with the pyenv Python installed version manager and environment:

# mkdir tmp_cvmeiuZ7wtsnQA32pM
# cd tmp_cvmeiuZ7wtsnQA32pM
# wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz
# tar -zvxf Python-3.7.0.tgz
# cd Python-3.7.0
# mkdir $(pyenv root)/versions/3.7.0
# ./configure --enable-framework=$(pyenv root)/versions/3.7.0/
# make
# make install
# cd $(pyenv root)/versions/Python-3.7.0rc1
# env PYTHON_CONFIGURE_OPTS="--enable-framework CC=clang" pyenv virtualenv 3.7.0 3.7.0
# cd ..
# rm -rf tmp_cvmeiuZ7wtsnQA32pM

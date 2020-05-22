pythonModules=" \
more_itertools \
colorspacious \
colour \
spectra \
numpy \
ciecam02 \
colormap \
colorgram \
Quartz \
Foundation \
Pillow"

# possible future-use modules:
# matplotlib \

# PACKAGE NOTES:
# colour is actually imported as colour-science, but there is another package that imports as colour. I think.
# Pillow is a maintained fork of PIL and imports as name PIL.

# Uncomment whichever applies to your python version:
#pipExeName=pip
pipExeName=pip3

for element in ${pythonModules[@]}
do
  $pipExeName install $element
done

# Source: http://stackoverflow.com/questions/25019287/how-to-convert-grayscale-values-in-matrix-to-an-image-in-python
import numpy
from matplotlib import pyplot as plt
x = numpy.random.rand(10, 10)*255
plt.imshow(x, cmap='gray', interpolation='nearest', vmin=0, vmax=255)
plt.savefig('text.png')
plt.show()

# FAIL--can't get dependencies properly installed.
# Try: http://stackoverflow.com/questions/30943966/how-can-i-create-a-png-image-file-from-a-list-of-pixel-values-in-python
# Or: http://stackoverflow.com/questions/27445694/creating-image-through-input-pixel-values-with-the-python-imaging-library-pil
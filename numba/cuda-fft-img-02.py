from __future__ import division
from numba import cuda
import numpy
import math
import numpy as np
import astropy.io.fits as fits
import matplotlib.pyplot  as plt

# CUDA kernel
@cuda.jit
def my_kernel(io_array):
    im = np.fft.fft2(io_array)
    im = np.fft.fftshift(im)
    io_array = np.fft.ifft2(im)
    

# Host code   
print ("FFT Started.....")
data = ((fits.open('1.fits')[0].data)).astype(np.complex128)
#data = numpy.ones(256)
threadsperblock = 256
blockspergrid = math.ceil(data.shape[0] / threadsperblock)
my_kernel[blockspergrid, threadsperblock](data)
#print(data)
plt.imshow(data, cmap='gray')
plt.colorbar()
plt.show()
from __future__ import division
#import numba
from numba import cuda
import pyculib.fft
import math
import numpy as np
import astropy.io.fits as fits
import matplotlib.pyplot  as plt


# CUDA kernel
#@numba.vectorize(['complex128(float64)'], target='cuda')
#@jit(nopython=True)
@cuda.jit('void(complex128[:],float64[:])')
def my_kernel(io_array,data):
    pyculib.fft.fft(data,im)
    #im=np.fft.fftshift(im)
    pyculib.fft.ifft(im,io_array)
    

# Host code   
print ("FFT Started.....")
imdata = ((fits.open('1.fits')[0].data)).astype(np.float64)
io_array = np.empty(imdata.shape[0],dtype=np.complex128)
#data = numpy.ones(256)
threadsperblock = 256
blockspergrid = math.ceil(imdata.shape[0] / threadsperblock)
my_kernel[blockspergrid, threadsperblock](io_array,imdata)
#print(data)
plt.imshow(io_array, cmap='gray')
plt.colorbar()
plt.show()
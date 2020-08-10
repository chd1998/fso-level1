from __future__ import division
#import numba
from numba import cuda
import pyculib.fft
import math
import numpy as np
import astropy.io.fits as fits
import matplotlib.pyplot  as plt

<<<<<<< HEAD

# CUDA kernel
#@numba.vectorize(['complex128(float64)'], target='cuda')
#@jit(nopython=True)
@cuda.jit('void(complex128[:],float64[:])')
def my_kernel(io_array,data):
    pyculib.fft.fft(data,im)
    #im=np.fft.fftshift(im)
    pyculib.fft.ifft(im,io_array)
=======
print ("FFT Started.....")
data=((fits.open('1.fits')[0].data)).astype(np.complex128)

# CUDA kernel
@cuda.jit
def my_kernel(io_array):
    im=np.fft.fft2(io_array)
    im=np.fft.fftshift(im)
    io_array=np.fft.ifft2(im)
>>>>>>> 7789f8e1690e4b39f5b49f80b27a3e8bb01e82ff
    
# Host code   
<<<<<<< HEAD
print ("FFT Started.....")
imdata = ((fits.open('1.fits')[0].data)).astype(np.float64)
io_array = np.empty(imdata.shape[0],dtype=np.complex128)
=======

>>>>>>> 7789f8e1690e4b39f5b49f80b27a3e8bb01e82ff
#data = numpy.ones(256)
threadsperblock = 256
blockspergrid = math.ceil(imdata.shape[0] / threadsperblock)
my_kernel[blockspergrid, threadsperblock](io_array,imdata)
#print(data)
plt.imshow(io_array, cmap='gray')
plt.colorbar()
plt.show()
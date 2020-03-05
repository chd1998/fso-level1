'''
fits-numba-gpu-xx.py

@author: chen dong @ fso
purposes: testing fft with parallel processes and gpu

Usage: python fits-numba-gpu-xx.py 
Example: python fits-numba-gpu-xx.py 

Changlog:
20200109	Release 0.1		prototype version with numba and pyculib
            
'''

import os
import datetime
import numpy as np
from numpy import fft
#import scipy.fftpack as fft
#import sys,click
import sys
#import cupy as cp
from multiprocessing import Pool
from astropy.io import fits
import random
from numba import jit
#from pyculib import fft

#@click.command()
#@click.option('--path', default=".", nargs=1, required=True, help='source path of imags')
#@click.option('--pn', default="1",nargs=1, required=True, type=int, help='process numbers, >=1')
#@click.option('--gpu', default="1",nargs=1, required=True, type=int, help='1 using gpu, 0 using cpu')
#@click.option('--gpunum', default="1",nargs=1, required=True, type=int, help='number of gpu(s)')

<<<<<<< HEAD
@jit(fastmath=True)
#@jit(fastmath=True,parallel=True,nogil=True)
#@jit(nopython=True,fastmath=True,parallel=True,nogil=True)
#@jit
=======
#@jit(fastmath=True)
>>>>>>> 702bb655808700ac018037f20e8e7f25fb723e1f
def myfft(fdata):
    im=fft.fft2(fdata)
    im=fft.fftshift(im)
    iim=fft.ifft2(im)
    return iim

image='d:\\fso-test\\1.fits'
print ("Calculating  %s" %(image))
fdata = ((fits.open(image)[0].data)).astype(np.complex128)
a = datetime.datetime.now()
myfft(fdata)
b = datetime.datetime.now()
delta = b - a
print("Total time used: %d ms" %(int(delta.total_seconds() * 1000)))
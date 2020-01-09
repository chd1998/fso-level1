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
#import scipy.fftpack as fft
import sys,click
import cupy as cp
from multiprocessing import Pool
from astropy.io import fits
import random
from numba import cuda
from pyculib import fft,sparse

#@click.command()
#@click.option('--path', default=".", nargs=1, required=True, help='source path of imags')
#@click.option('--pn', default="1",nargs=1, required=True, type=int, help='process numbers, >=1')
#@click.option('--gpu', default="1",nargs=1, required=True, type=int, help='1 using gpu, 0 using cpu')
#@click.option('--gpunum', default="1",nargs=1, required=True, type=int, help='number of gpu(s)')

@cuda.jit
def myfft(fdata):
    im = fft.fftn(fdata)
    im = fft.fftshift(im)
    iim = fft.ifftn(im)
    return iim

image='d:\\ximage\\000_003_cubesub.fits'
print ("Calculating  %s" %(image))
fdata = ((fits.open(image)[0].data)).astype(np.complex128)
a = datetime.datetime.now()
myfft(fdata)
b = datetime.datetime.now()
delta = b - a
print("Total time used: %d ms" %(int(delta.total_seconds() * 1000)))
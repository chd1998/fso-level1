'''
fits-single-ximage-xx.py
@author: chen dong @ fso
purposes: testing fft with single process

Usage: python fits-single-ximage-xx.py --path=<inputpath> 
Example: python fits-single-ximage-xx.py --path=d:\\ximage 

20200109	Release 0.1		prototype version both in single & parallel version


'''
import os
#import PIL
import datetime
import numpy as np
import astropy.io.fits as fits
#import scipy.fftpack as fft
import sys, click
#import numba 
from numba.cuda import jit
#from pyculib import fft
#from PIL import Image
from astropy.io import fits
from numba import findlib

#@click.command()
#@click.option('--path', default=".",nargs=1, required=True, help='source path of imags')
path='d:\\ximage'

print ("FFT Started.....")
fdata = ((fits.open('d:\\ximage\\000_000_cubesub.fits')[0].data)).astype(np.complex128)
d,m,n = fdata.shape
a = datetime.datetime.now()
im = np.fft.fftn(fdata)
im = np.fft.fftshift(im)
iim = np.fft.ifftn(im)
print ("FFT Ended.....")
b = datetime.datetime.now()
delta = b - a
print ("Total Time: %d ms" %(int(delta.total_seconds() * 1000)))

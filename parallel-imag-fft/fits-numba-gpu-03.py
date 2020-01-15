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
#from numpy import fft
#import scipy.fftpack as fft
import sys,click
import sys
#import cupy as cp
from multiprocessing import Pool
from astropy.io import fits
import random
from numba import jit
#from pyculib import fft

@click.command()
@click.option('--path', default=".", nargs=1, required=True, help='source path of imags')
#@click.option('--pn', default="1",nargs=1, required=True, type=int, help='process numbers, >=1')
#@click.option('--gpu', default="1",nargs=1, required=True, type=int, help='1 using gpu, 0 using cpu')
#@click.option('--gpunum', default="1",nargs=1, required=True, type=int, help='number of gpu(s)')

def gputest(path):
    images=get_image_paths(path)
    tnum=0
    a = datetime.datetime.now()
    for image in images:
        print ("%d : Calculating  %s" %(tnum,image))
        fdata = ((fits.open(image)[0].data)).astype(np.complex128)
        fftresult=myfft(fdata)
        tnum += 1
    b = datetime.datetime.now()
    delta = b - a
    print("Total time used: %d ms" %(int(delta.total_seconds() * 1000)))

def get_image_paths(path):
    return (os.path.join(path, f)
            for f in os.listdir(path)
            if 'fits' in f)

#@jit(fastmath=True,parallel=True,nogil=True)
#@jit(nopython=True,fastmath=True,parallel=True,nogil=True)
#@jit
def myfft(fim):
    #cp.cuda.Device(0).use()
    im=np.fft.fftn(fim)
    im=np.fft.fftshift(im)
    iim=np.fft.ifftn(im)
    return iim

if __name__ == '__main__':
    gputest()

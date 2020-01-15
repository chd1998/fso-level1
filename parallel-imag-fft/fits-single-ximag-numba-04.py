'''
fits-single-ximage-xx.py
@author: chen dong @ fso
purposes: testing fft with single process

Usage: python fits-single-ximage-xx.py --path=<inputpath> 
Example: python fits-single-ximage-xx.py --path=d:\\ximage 

20191207	Release 0.1		prototype version both in single & parallel version
20191212    Release 0.2     revised
20191217    Release 0.3     using fftn instead of fft2

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
#from PIL import Image
from astropy.io import fits

#@click.command()
#@click.option('--path', default=".",nargs=1, required=True, help='source path of imags')
path='d:\\ximage'
images=[]

def fsingle(images): 
    tmpnum = 0
    for image in images:
        #print ('%4d : %s' %(tmpnum,image))
        fdata = ((fits.open(image)[0].data)).astype(np.complex64)
        d,m,n = fdata.shape
        im = np.fft.fftn(fdata)
        im = np.fft.fftshift(im)
        iim = np.fft.ifftn(im)
        tmpnum=tmpnum+1
    #print ("fft finished!")
   
    #return iim

def get_image_paths(folder):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if 'fits' in f)

#if __name__ == '__main__':
print ("FFT Started.....")
folder = os.path.realpath(path)
if not os.path.isdir(os.path.join(folder)):
    print ("Folder %s doesn't exist!  Pls Check..." % path)
    sys.exit
images = get_image_paths(folder)
a = datetime.datetime.now()
fsingle(images)
print ("FFT Ended.....")
b = datetime.datetime.now()
delta = b - a
print (" Total Time: %d ms" %(int(delta.total_seconds() * 1000)))

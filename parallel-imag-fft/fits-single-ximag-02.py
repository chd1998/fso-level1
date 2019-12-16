'''
fits-single-ximage-xx.py
@author: chen dong @ fso
purposes: testing fft with single process

Usage: python fits-single-ximage-xx.py --path=<inputpath> 
Example: python fits-single-ximage-xx.py --path=d:\\ximage 

20191207	Release 0.1		prototype version both in single & parallel version

'''
import os
#import PIL
import datetime
import numpy as np
import astropy.io.fits as fits
import scipy.fftpack as fft
import sys, click

#from PIL import Image
from astropy.io import fits

@click.command()
@click.option('--path', default=".",nargs=1, required=True, help='source path of imags')


def fsingle(path): 
    folder = os.path.realpath(path)
    if not os.path.isdir(os.path.join(folder)):
        print ("Folder %s doesn't exist!  Pls Check..." % path)
        exit

    
    #click.echo("%s" %(path))
    
    images = get_image_paths(folder)
    print ("Starting Calculating FFT...")
    a = datetime.datetime.now()
    tmpnum = 0
    for image in images:
        print ('%4d : %s' %(tmpnum,image))
        tmpnum +=1
        fdata = (fits.open(image))[0].data
        d,m,n = fdata.shape
        for i in range(d):
            ximage = fdata[i].astype(np.float)
            im = fft.fft2(ximage)
            im = fft.fftshift(im)
            iim = fft.ifft2(im)
        
    print ("fft finished!")
    
    b = datetime.datetime.now()
    delta = b - a
    print ("Time Used with 1 process : %d ms" %(int(delta.total_seconds() * 1000)))

def get_image_paths(folder):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if 'fits' in f)

if __name__ == '__main__':
    fsingle()

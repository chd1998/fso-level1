'''
fits-parallel-ximag-xx.py

@author: chen dong @ fso
purposes: testing fft with single process

Usage: python fits-parallel-ximag-xx.py --path=<inputpath> --pn=<process numbers>
Example: python fits-parallel-ximag-xx.py --path=d:\\ximage --pn=1

Changlog:
20191207	Release 0.1		prototype version both in single & parallel version

'''

import os
#import PIL
import datetime
import numpy as np
import scipy.fftpack as fft
import sys,click
#import getopt

#from PIL import Image
from multiprocessing import Pool
from astropy.io import fits

@click.command()
@click.option('--path', default=".", required=True, help='source path of imags')
@click.option('--pn', default="1", required=True, type=int, help='process numbers')


def fparallel(path,pn):
    folder = os.path.realpath(path)
    if not os.path.isdir(os.path.join(folder)):
	    print ("Folder %s doesn't exist!  Pls Check..." % path)
    else:
        print("Starting FFT with %d process(es)..." %( pn ))
        
        images = get_image_paths(folder)
        a = datetime.datetime.now()
        pool = Pool(processes=pn)
        fftresult = pool.map_async(myfft, images)
        pool.close()
        pool.join()
        b = datetime.datetime.now()
        delta = b - a
        print("Time Used With %d Process(es) : %d ms" %(pn, int(delta.total_seconds() * 1000)))


def get_image_paths(folder):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if 'fits' in f)


def myfft(image):
    fdata = ((fits.open(image)[0].data)).astype(np.float)
    d,m,n = fdata.shape
    #ximage = (fdata[0].data).astype(np.float)
    print ("Calculating  %s" %(image))
	#ximage=np.fft.fft2(fdata[0].data)
    for i in range(d):
        im = fft.fft2(fdata[i])
        im = fft.fftshift(im)
        iim = fft.ifft2(im)
    return iim
    
if __name__ == '__main__':
    fparallel()

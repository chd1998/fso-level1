'''
fits-parallel-ximag-gpu-xx.py

@author: chen dong @ fso
purposes: testing fft with parallel processes and gpu

Usage: python fits-parallel-ximag-gpu-xx.py --path=<inputpath> --pn=<process numbers>
Example: python fits-parallel-ximag-gpu-xx.py --path=d:\\ximage --pn=1

Changlog:
20191207	Release 0.1		prototype version both in single & parallel version

'''

import os
#import PIL
import datetime
import numpy as np
#import scipy.fftpack as fft
import sys,click
import cupy as cp
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
        print("Starting FFT with %d process(es) and GPU..." %pn )
        
        images = get_image_paths(folder)
        a = datetime.datetime.now()
        pool = Pool(processes=pn)
        fftresult = pool.map(myfft, images)
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
    fdata = fits.open(image)
    ximage = (fdata[0].data).astype(np.float)
    M,N,O = ximage.shape
    #print(ximage.shape)
    im = np.ndarray((M,N,O),dtype=np.complex64)
    print ("Calculating  %s" %(image))
    #ximage=np.fft.fft2(fdata[0].data)
    #fftok = fft.fft2(ximage)
    cp.cuda.Device(0).use()
    with cp.cuda.Device(0):
        s_gpu = cp.ndarray((M,N,O),dtype=np.complex64)
        s_gpu = cp.asarray(ximage)
        s_gpu = cp.fft.fft2(s_gpu)
        im = cp.asnumpy(s_gpu)
    return  im

if __name__ == '__main__':
    fparallel()

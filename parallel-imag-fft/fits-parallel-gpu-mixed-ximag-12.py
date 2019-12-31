'''
fits-parallel-ximag-gpu-xx.py

@author: chen dong @ fso
purposes: testing fft with parallel processes and gpu

Usage: python fits-parallel-ximag-gpu-xx.py --path=<inputpath> --pn=<process numbers>
Example: python fits-parallel-ximag-gpu-xx.py --path=d:\\ximage --pn=1

Changlog:
20191207	Release 0.1		prototype version both in single & parallel version
20191210    Release 0.2     using pool.apply_async instead of pool.map
20191211    Release 0.3     using pool.map_async instead of pool.apply_async
20191213    Release 0.4     using multi-gpu devices
            Release 0.5     using pool.apply_async
            Release 0.6     using map.async, process number and gpu number as parameters
20191215    Release 0.7     Testing pandas dataframe
20191216    Release 0.8     using starmap_asysnc
            Release 0.9     making multi-gpu working simultaneously
            Release 1.0     assign gpu randomly
20191217    Release 1.1     optimize
            Release 1.2     using cupy.fft.fftn instead of fft2
            
'''

import os
import datetime
import numpy as np
import scipy.fftpack as fft
import sys,click
import cupy as cp
from multiprocessing import Pool
from astropy.io import fits
import random

@click.command()
@click.option('--path', default=".", nargs=1, required=True, help='source path of imags')
@click.option('--pn', default="1",nargs=1, required=True, type=int, help='process numbers, >=1')
@click.option('--gpu', default="1",nargs=1, required=True, type=int, help='1 using gpu, 0 using cpu')
@click.option('--gpunum', default="1",nargs=1, required=True, type=int, help='number of gpu(s)')



def fparallel(path,pn,gpu,gpunum):
    folder = os.path.realpath(path)
    if not os.path.isdir(os.path.join(folder)):
        print ("Folder %s doesn't exist!  Pls Check..." % path)
    else:
        images = get_image_paths(folder)
        a = datetime.datetime.now()
        pool = Pool(processes=pn)
        if gpu == 1:
            print("Starting FFT with %d process(es) and GPU..." %pn )
            args = []
            gpuid = 0
            for image in images:
                args.append([image,gpunum,gpuid])
                gpuid = random.randint(0,gpunum-1)
            fftresult = pool.starmap_async(myfft_gpu, args)
        else: 
            print("Starting FFT with %d process(es)..." %pn )
            fftresult = pool.map_async(myfft, images)
        pool.close()
        pool.join()
        b = datetime.datetime.now()
        delta = b - a
        if (gpu==0):
            print("Time Used With %d Process(es) : %d ms" %(pn, int(delta.total_seconds() * 1000)))
        else:
            print("Time Used With %d Process(es) + GPU: %d ms" %(pn, int(delta.total_seconds() * 1000)))


def get_image_paths(folder):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if 'fits' in f)

def myfft_gpu(image,gpunum,gpuid):
    fdata = (fits.open(image))[0].data
    d,m,n = fdata.shape
    im = np.ndarray((d,m,n),dtype=np.complex64)
    cp.cuda.Device(gpuid).use()
    with cp.cuda.Device(gpuid):
        #s_gpu = cp.ndarray((m,n),dtype=np.complex64)
        #r_gpu = cp.ndarray((m,n),dtype=np.complex64)
        s_gpu = cp.asarray(im)
        s_gpu = cp.fft.fftn(s_gpu)
        s_gpu = cp.fft.ifftshift(s_gpu)
        r_gpu = cp.fft.irfftn(s_gpu)
        cp.cuda.Stream.null.synchronize()
        im = cp.asnumpy(r_gpu)
    print ("Calculating %s  with gpu %d" %(image,gpuid))
    #gpuid=random.randint(0,gpunum-1)
    return  im

def myfft(image):
    fdata = ((fits.open(image)[0].data)).astype(np.complex64)
    d,m,n = fdata.shape
    #ximage = (fdata[0].data).astype(np.complex64)
    print ("Calculating  %s" %(image))
	#ximage=np.fft.fft2(fdata[0].data)
    #for i in range(d):
    im = fft.fftn(fdata)
    im = fft.fftshift(im)
    iim = fft.ifftn(im)
    return iim

if __name__ == '__main__':
    fparallel()

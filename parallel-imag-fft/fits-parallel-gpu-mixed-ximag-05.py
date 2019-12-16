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
20191223    Release 0.4     using multi-gpu devices 

'''

import os
import datetime
import numpy as np
import scipy.fftpack as fft
import sys,click
import cupy as cp
from multiprocessing import Pool
from astropy.io import fits

gpun = 1 # 4 gpu devs
gpuid = 0 # gpu dev indx
#gpunum = 1 # gpu number used
@click.command()
@click.option('--path', default=".", nargs=1, required=True, help='source path of imags')
@click.option('--pn', default="1",nargs=1, required=True, type=int, help='process numbers, >=1')
@click.option('--gpu', default="1",nargs=1, required=True, type=int, help='1 using gpu, 0 using cpu')
@click.option('--gpunum', default="1",nargs=1, required=True, type=int, help='number of gpu devices used')


def fparallel(path,pn,gpu,gpunum):
    gpun = gpunum
    folder = os.path.realpath(path)
    if not os.path.isdir(os.path.join(folder)):
        print ("Folder %s doesn't exist!  Pls Check..." % path)
    else:
        if gpu == 1:
            print("Starting FFT with %d process(es) and GPU..." %pn )
        else: 
            print("Starting FFT with %d process(es)..." %pn )
        
        images = get_image_paths(folder)
        #for image in images:
        #    print(image)
        print(" ")
        a = datetime.datetime.now()
        #cpus = multiprocessing.cpu_count()
        #fftresults = []
        pool = Pool(processes=pn)
        if gpu==1:
            #fftresult = pool.apply_async(myfft_gpu, args=(fdata,d,m,n))
            fftresult = pool.map_async(myfft_gpu,images)
            #fftresults.append(fftresult)
        else:
            #fftresult = pool.apply_async(myfft, args=(fdata,d,m,n))
            fftresult = pool.map_async(myfft,images)
            #fftresults.append(fftresult)
                        
        pool.close()
        pool.join()
        
        b = datetime.datetime.now()
        #for fftresult in fftresults:
        #    print(fftresult.get())
        delta = b - a
        if (gpu==0):
            print("Time Used With %d Process(es) : %d ms" %(pn, int(delta.total_seconds() * 1000)))
        else:
            print("Time Used With %d Process(es) + GPU: %d ms" %(pn, int(delta.total_seconds() * 1000)))


def get_image_paths(folder):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if 'fits' in f)

def myfft_gpu(image):
    print ("Processing %40s...." %(image))
    fdata = (fits.open(image))[0].data
    d,m,n = fdata.shape
    global gpun,gpuid
    #print ("Using gpu %d" %(gpuid))
    for i in range(d):
        ximage = fdata[i]
        #im = np.ndarray((m,n),dtype=np.complex64)
        global gpuid
        cp.cuda.Device(gpuid).use()
        with cp.cuda.Device(gpuid):
            #s_gpu = cp.ndarray((m,n),dtype=np.complex64)
            #r_gpu = cp.ndarray((m,n),dtype=np.complex64)
            s_gpu = cp.asarray(ximage)
            s_gpu = cp.fft.fft2(s_gpu)
            s_gpu = cp.fft.ifftshift(s_gpu)
            r_gpu = cp.fft.ifft2(s_gpu)
            cp.cuda.Stream.null.synchronize()
            im = cp.asnumpy(r_gpu)
    gpuid = (gpuid + 1) % gpun
    return  im

def myfft(image):
    print ("Processing %40s..." %(image))
    fdata = (fits.open(image))[0].data
    d,m,n = fdata.shape
    #print (d)
    for i in range(d):
        ximage = fdata[i].astype(np.float32)
        im = fft.fft2(ximage)
        im = fft.fftshift(im)
        iim = fft.ifft2(im)
    
    return iim

if __name__ == '__main__':
    fparallel()

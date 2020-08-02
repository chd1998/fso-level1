'''
mpi-pic-xx.py

@author: chen dong @ fso
purposes: demo image processing using mpi
Note: 

Usage: mpiexec -n x python mpi-pic-xx.py --path=<path>
Example: mpiexec -n 2 python mpi-pic-xx.py d:\fso-data


Changlog:
20200103	Release 0.1		prototype version 
20200105	Release 0.2     using numba jit
20200107    Release 0.3     using click to input argvs
20200730    Release 0.4     using fire to input argvs

'''
import numpy as np
from skimage import data, img_as_float
from skimage.restoration import denoise_tv_chambolle, denoise_bilateral,denoise_tv_bregman
import skimage.io
import os.path
import time
from mpi4py import MPI
from numba import jit
import fire
import sys

#curPath = os.path.abspath(os.path.curdir)
#path="d:\\fso-data\\mpi"
#@click.command()
#@click.option('--path', default=".", nargs=1, required=True, help='path of source images')

def mpipic(path):
    #curPath=path
    parallel(path)

@jit
def denoise(imgFiles,rank,path):
    for f in imgFiles:
        startTime = time.time()
        base, fname = os.path.split(f)
        img = img_as_float(data.load(f))
        img = denoise_bilateral(img)
        outimg = os.path.join(path,'denoised',fname)
        skimage.io.imsave(outimg, img)
        print ("Process %d: Saving %s to %s using %f seconds" %(rank, f, outimg,time.time() - startTime))

def parallel(path):
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()
    totalStartTime = time.time()
    #noisyDir = os.path.join(path,'noisy')
    noisyDir=path
    if not os.path.isdir(os.path.join(noisyDir)):
        print ("Source image dir %s doesn't exist!  Pls Check..." % noisyDir)
        sys.exit(0)
    denoisedDir = os.path.join(path,'denoised')
    if not os.path.isdir(os.path.join(denoisedDir)):
        os.makedirs(denoisedDir)
    oimgFiles = get_image_paths(noisyDir,"jpg")
    imgFiles = list(oimgFiles)
    filenum = 0
    for img in imgFiles:
        filenum = filenum + 1
    if filenum == 0:
        print ("No jpg file(s) found in %s, pls check..." % path)
        sys.exit(1)
    numFiles = np.int(filenum/size) #number of files this process will handle
    #imgFiles = ["%.4d.jpg"%x for x in range(rank*numFiles+1, (rank+1)*numFiles+1)] # Fix this line to distribute imgFiles
    ntmp = 0
    nimgFiles = np.asarray(imgFiles)
    for x in range(rank*numFiles,(rank+1)*numFiles):
        nimgFiles[ntmp] = imgFiles[x]
        ntmp = ntmp + 1
    xtmp=(rank+1)*numFiles
    nftmp=filenum % size
    if (filenum % size != 0 and rank == size):
        for y in range(0,nftmp):
            nimgFiles[ntmp] = imgFiles[xtmp+y]
            ntmp=ntmp+1
    denoise(nimgFiles,rank,path)
    #assert denoise.nopython_signatures
    print ("Total time %f seconds" %(time.time() - totalStartTime))

def get_image_paths(folder,filetype):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if filetype in f)

if __name__=='__main__':
    fire.Fire(mpipic)


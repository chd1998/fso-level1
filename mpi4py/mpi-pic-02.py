import numpy as np
from skimage import data, img_as_float
from skimage.restoration import denoise_tv_chambolle, denoise_bilateral,denoise_tv_bregman
import skimage.io
import os.path
import time
from mpi4py import MPI
from numba import jit
#curPath = os.path.abspath(os.path.curdir)
curPath="d:\\fso-test\\mpi"
noisyDir = os.path.join(curPath,'noisy')
denoisedDir = os.path.join(curPath,'denoised')

#@jit
def denoise(imgFiles,rank):
    for f in imgFiles:
        startTime = time.time()
        base, fname = os.path.split(f)
        img = img_as_float(data.load(f))
        img = denoise_bilateral(img)
        outimg = os.path.join(curPath,'denoised',fname)
        skimage.io.imsave(outimg, img)
        print ("Process %d: Saving %s to %s using %f seconds" %(rank, f, outimg,time.time() - startTime))

def parallel():
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()
    totalStartTime = time.time()
    oimgFiles = get_image_paths(noisyDir,"jpg")
    imgFiles = list(oimgFiles)
    filenum = 0
    for img in imgFiles:
        filenum = filenum + 1
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
    denoise(nimgFiles,rank)
    #assert denoise.nopython_signatures
    print ("Total time %f seconds" %(time.time() - totalStartTime))

def get_image_paths(folder,filetype):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if filetype in f)

if __name__=='__main__':
    parallel()


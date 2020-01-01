import numpy as np
from skimage import data, img_as_float
from skimage.restoration import denoise_tv_chambolle, denoise_bilateral,denoise_tv_bregman
import skimage.io
import os.path
import time
from mpi4py import MPI
from numba import jit
#curPath = os.path.abspath(os.path.curdir)
curPath="d:\\fso-data\\mpi"
noisyDir = os.path.join(curPath,'noisy')
denoisedDir = os.path.join(curPath,'denoised')

#@jit
def denoise(imgFiles,rank):
    for f in imgFiles:
        #img = img_as_float(data.load(os.path.join(noisyDir,f)))
        #print (f)
        img = np.float(data.load(os.path.join(noisyDir,f)))
        startTime = time.time()
        img = denoise_bilateral(img)
        skimage.io.imsave(os.path.join(denoisedDir,f), img)
        print ("Process %d: Took %f seconds for %s" %(rank, time.time() - startTime, f))

def parallel():
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()
    totalStartTime = time.time()
    oimgFiles = get_image_paths(noisyDir,"jpg")
    imgFiles = list(oimgFiles)
    filenum = 0
    for img in imgFiles:
    #    print (img)
        filenum = filenum + 1
    #filenum = len(imgFiles)
    numFiles = np.int(filenum/size) #number of files this process will handle
    #print (size)
    #print (numFiles)
    #imgFiles = ["%.4d.jpg"%x for x in range(rank*numFiles+1, (rank+1)*numFiles+1)] # Fix this line to distribute imgFiles
    ntmp = 0
    nimgFiles = np.array(numFiles,dtype=str)
    #print(len(nimgFiles))
    #print(imgFiles.shape)
    for x in range(rank*numFiles+1,(rank+1)*numFiles+1):
        nimgFiles[ntmp] = enumerate(imgFiles[x])
        ntmp = ntmp + 1
    denoise(nimgFiles,rank)
    #assert denoise.nopython_signatures
    print ("Total time %f seconds" %(time.time() - totalStartTime))

def get_image_paths(folder,filetype):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if filetype in f)

if __name__=='__main__':
    parallel()


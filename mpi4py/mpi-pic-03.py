import numpy as np
from skimage import data, img_as_float
from skimage.restoration import denoise_tv_chambolle, denoise_bilateral,denoise_tv_bregman
import skimage.io
import os.path
import time
from mpi4py import MPI
from numba import jit
import click,sys

#curPath = os.path.abspath(os.path.curdir)
#path="d:\\fso-data\\mpi"
@click.command()
@click.option('--path', default=".", nargs=1, required=True, help='path of source images')

def main(path):
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
    noisyDir = os.path.join(path,'noisy')
    if not os.path.isdir(os.path.join(noisyDir)):
        print ("Source image dir %s doesn't exist!  Pls Check..." % noisyDir)
        sys.exit(0)
    denoisedDir = os.path.join(path,'denoised')
    if not os.path.isdir(os.path.join(denoisedDir)):
        #print ("Folder %s doesn't exist!  Pls Check..." % denoiseDir)
        os.makedirs(denoisedDir)
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
    denoise(nimgFiles,rank,path)
    #assert denoise.nopython_signatures
    print ("Total time %f seconds" %(time.time() - totalStartTime))

def get_image_paths(folder,filetype):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if filetype in f)

if __name__=='__main__':
    main()


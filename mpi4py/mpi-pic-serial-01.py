import numpy as np
from skimage import data, img_as_float
from skimage.restoration import denoise_bilateral
import skimage.io
import os.path
import time
#curPath = os.path.abspath(os.path.curdir)
curPath="d:\\fso-data\\mpi"
noisyDir = os.path.join(curPath,'noisy')
denoisedDir = os.path.join(curPath,'denoised')

def loop(imgFiles):
    num = 0
    for f in imgFiles:
        startTime = time.time()
        #img = img_as_float(skimage.io.imread(os.path.join(noisyDir,f)))
        #inimg = os.path.join(noisyDir,f)
        base, fname = os.path.split(f)
        #print(fname)
        img = img_as_float(data.load(f))
        img = denoise_bilateral(img)
        #int_img=np.uint8(img)
        outimg = os.path.join(curPath,'denoised',fname)
        #print (outimg)
        #print (f)
        skimage.io.imsave(outimg, img)
        print("%d : saving %s to %s using %f secs" %(num, f, outimg, time.time() - startTime))
        num = num + 1

def serial():
    total_start_time = time.time()
    #imgFiles = ["%.4d.jpg"%x for x in range(1,101)]
    imgFiles = get_image_paths(noisyDir,"jpg")
    #for img in imgFiles:
    #    print (img)
    loop(imgFiles)
    print("Total time %f seconds" %(time.time() - total_start_time))

def get_image_paths(folder,filetype):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if filetype in f)

if __name__=='__main__':
    serial()
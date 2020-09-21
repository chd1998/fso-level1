'''
sift-cv-xx.py

@author: chen dong @ fso
purposes: sift using cv

Usage: python sift-cv-xx.py input output
Example: python sift-cv-xx.py d:\fso-data\fso-test-data  result.jpg


Changlog:
20200914	Release 0.1		prototype version
20200915    Release 0.2     using ha raw data(jpg) 

'''

import os,sys
import PIL
import datetime
import numpy as np
import fire
import cv2
import Utility01

from PIL import Image
from multiprocessing import Pool
from astropy.io import fits

def siftcv(path,savedir):
    folder = os.path.realpath(path)
    if not os.path.isdir(os.path.join(folder)):
        print ("Folder %s doesn't exist!  Pls Check..." % path)
        sys.exit(0)
    else:
        if not os.path.isdir(os.path.join(folder, savedir)):
            os.makedirs(os.path.join(folder, savedir))

        images = get_image_paths(folder)
        #lenImg=0
        arrayImg=[]
        for image in images:
            arrayImg.append(image)
        #print(len(arrayImg))
        refImg=arrayImg[0]
        imdata1,imtmp1,htmp=fits_open(refImg)
        #print(arrayImg[0])
        finalImg=np.zeros(shape=imdata1.shape)
        a = datetime.datetime.now()
        #print(lenImg)
        i=1
        for i in range(len(arrayImg)):
            print("Aligning %s to %s..." %(arrayImg[i],refImg))
            #print(arrayImg[i])
            tmp,finalImg=align_fits(refImg,arrayImg[i])
            refImg=tmp
            i=i+1
        
        b = datetime.datetime.now()
        delta = b - a
        print("Time Used with : %d ms" %( int(delta.total_seconds() * 1000)))
        im1=fits.open(arrayImg[1])
        im2=fits.open(tmp)
        myimg1=im1[0].data
        myimg2=im2[0].data
        allImg = np.concatenate((myimg1,myimg2,finalImg),axis=1)
        cv2.namedWindow('Result',cv2.WINDOW_NORMAL)
        cv2.imshow('Result',allImg)
        cv2.waitKey(0)

def get_image_paths(folder):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if 'fits' in f)

def fits_open(fname):
    hud = fits.open(fname)
    imtmp = hud[0].data
    header=hud[0].header
    immax = np.max(hud[0].data)
    immin = np.min(hud[0].data)
    im1 = ((imtmp - immin) / (immax - immin)) * 255
    im1 = im1.astype('uint8')
    hud.close()
    return imtmp,im1,header

def fits_write(header,imdata,destname):
#    hud = fits.open(srcname)
#    header = hud.header
    #while len(header)<(36*4-1):
    #    header.append()
    #header.tofile(destname,overwrite=True)
    hud=fits.PrimaryHDU(imdata)
    hudlist=fits.HDUList([hud])
    #hudlist.append(hud)
    hudlist.writeto(destname,overwrite=True)
 

def align_fits(imgname1,imgname2):
#    img1 = cv2.imread(img1)
#    img2 = cv2.imread(img2)
    img1,img11,h1=fits_open(imgname1)
    img2,img21,h2=fits_open(imgname2)
    result,_,_ = Utility01.siftImageAlignment(img11,img21)
    #allImg = np.concatenate((img1,img2,result),axis=1)
    tmpName="tmp.fits"
#    cv2.imwrite(tmpName,result)
    fits_write(h1,result,tmpName)    
    return tmpName,result

if __name__ == '__main__':
    fire.Fire(siftcv)
    
    

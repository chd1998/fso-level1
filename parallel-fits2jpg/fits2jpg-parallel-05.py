'''
fits2jpg-parallel-xx.py

@author: chen dong @ fso
purposes: generating the jpeg thumbnails of fits files in source SAVE_DIRECTORY
Note: single --- using 1 process; parallel --- using specific number of processes via input

Usage: python fits2jpg-parallel-xx.py --path=<str> --pn=<int> --tsize=int int --savedir=<str>
Example: python fits2jpg-parallel-04.py --path=d:\\fso-data\\fso-test-data --pn=4 --tsize=256 256 --savedir=thumbs


Changlog:
20190701	Release 0.1		prototype version both in single & parallel version
20190705	Release 0.2     revised, add input argvs
20191212    Release 0.3     using click to input argvs
20191213    Release 0.4     using map_async instead of map
                            using tuple(x,y) instead of x,y
20200730    Release 0.5     using fire for input arguments

'''

import os
import PIL
import datetime
import numpy as np
import sys,click
import fire

from PIL import Image
from multiprocessing import Pool
from astropy.io import fits
TSIZE=(256,256)
SAVEDIR="thumbs"

def f2jp(path,pn,tsize,savedir):
    TSIZE=tsize
    SAVEDIR=savedir

    folder = os.path.realpath(path)
    if not os.path.isdir(os.path.join(folder)):
        print ("Folder %s doesn't exist!  Pls Check..." % path)
    else:
        if not os.path.isdir(os.path.join(folder, savedir)):
            os.makedirs(os.path.join(folder, savedir))

        images = get_image_paths(folder)
        #for image in images:
        #    print (image)
        a = datetime.datetime.now()
        pool = Pool(processes=pn)
        print("Converting...")

        pool.map_async(create_thumbnail, images)

        pool.close()
        pool.join()
        b = datetime.datetime.now()
        delta = b - a
        print("Time Used with %d thread : %d ms" %(pn, int(delta.total_seconds() * 1000)))


def get_image_paths(folder):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if 'fits' in f)


def create_thumbnail(filename):
    #print (TSIZE)
    hud = fits.open(filename)
    immax = np.max(hud[0].data)
    immin = np.min(hud[0].data)
    im1 = ((hud[0].data - immin) / (immax - immin)) * 255
    im1 = im1.astype('uint8')
    #im1 = im1.astype(np.int8)
    hud.close()
    #tmp = tmp.astype(np.int32)
    im = Image.fromarray(im1, mode="L")
    im.thumbnail(TSIZE, Image.ANTIALIAS)
    # im.resize(SIZE)
    base, fname = os.path.split(filename)
    #print(base,fname)
    fname = fname + ".jpg"
    save_path = os.path.join(base, SAVEDIR, fname)
    print("Converting %s to %s" % (filename, save_path))
    im.save(save_path)

if __name__ == '__main__':
    fire.Fire(f2jp)

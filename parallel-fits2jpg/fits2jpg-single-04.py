'''
fits2jpg-single-xx.py
@author: chen dong @ fso
purposes: generating the jpeg thumbnails of fits files in source SAVE_DIRECTORY

Usage: python fits2jpg-single-xx.py  src (sx,sy) dest
Example: python fits2jpg-single-xx.py -p d:\fso-test (256,256) thumbs

20190701	Release 0.1		prototype version both in single & parallel version
20190705	Release 0.2     revised, add input argvs
20200730    Release 0.3     using fire to input argvs

'''
import os
import PIL
import datetime
import numpy as np
import sys
import fire

from PIL import Image
from astropy.io import fits

SIZE = (256,256)	#default thumbnail size 256*256
SAVE_DIRECTORY = 'thumbs' #default directory for thumbnail
T_DIR = "."  #default source file(s) directory is current directory

def f2js(path,tsize,savedir):
    T_DIR = path
    SIZE = tsize
    SAVE_DIRECTORY = savedir
    folder = os.path.realpath(T_DIR)
    if not os.path.isdir(os.path.join(folder)):
        print("%s is not exist, pls check..." %T_DIR)
        sys.exit(0)

    if not os.path.isdir(os.path.join(folder, SAVE_DIRECTORY)):
        os.makedirs(os.path.join(folder, SAVE_DIRECTORY))
    images = get_image_paths(folder)
    a = datetime.datetime.now()
    print ("Start Converting fits file(s) to jpg file(s)...")
    tmpnum=1
    for image in images:
        print ('%8d : %s' %(tmpnum,image))
        create_thumbnail(image)
        tmpnum +=1
    b = datetime.datetime.now()
    delta = b - a
    print ("Time Used with 1 thread : %d ms" %(int(delta.total_seconds() * 1000)))

def get_image_paths(folder):
	return (os.path.join(folder, f)
			for f in os.listdir(folder)
			if 'fits' in f)

def create_thumbnail(filename):
	hud = fits.open(filename)
	immax = np.max(hud[0].data)
	immin = np.min(hud[0].data)
	im1 = ((hud[0].data-immin)/(immax-immin))*255
	im1 = im1.astype('uint8')
	hud.close()
	im = Image.fromarray(im1,mode="L")
	im.thumbnail(SIZE, Image.ANTIALIAS)
	base, fname = os.path.split(filename)
	fname = fname+".jpg"
	save_path = os.path.join(base, SAVE_DIRECTORY, fname)
	im.save(save_path)
	print("           To  %s" %(save_path))
	
if __name__ == '__main__':
	fire.Fire(f2js)

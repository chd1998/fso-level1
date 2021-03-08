'''
jpg-resize-xx.py
@author: chen dong @ fso
purposes: resize jpg files for data
Usage: python jpg-resize-xx.py  src dest x y
Example: python jpg-resize-xx.py d:\data d:\newdata 512 512

20210223	Release 0.1.0		prototype version

'''

import os
import PIL
import datetime
import numpy as np
import sys
import fire

from PIL import Image

def jresize(path,savedir,tsx,tsy):
    TSIZE=(tsx,tsy)
    SAVEDIR=savedir

    folder = os.path.realpath(path)
    if not os.path.isdir(os.path.join(folder)):
        print ("Folder %s doesn't exist!  Pls Check..." % path)
        sys.exit(0)
    else:
        if not os.path.isdir(os.path.join(folder, savedir)):
            os.makedirs(os.path.join(folder, savedir))

        images = get_image_paths(folder)
        #for image in images:
        #    print (image)
        a = datetime.datetime.now()
        print ("Start Converting fits file(s) to jpg file(s)...")
        tmpnum=1
        for image in images:
            try:
                img=Image.open(image)
                new_img = img.resize((tsx, tsy), Image.BILINEAR)
                #if new_img.mode == 'P':
                #    new_img = new_img.convert("RGB")
                #if new_img.mode == 'RGBA':
                #    new_img = new_img.convert("RGB")
                newname=str(tsx)+"-"+str(tsy)+"-"+image
                #print(newname)
                new_img.save(os.path.join(savedir, os.path.basename(newname)))
                print ('%8d : %s  %s' %(tmpnum,image,newname))
            except Exception as e:
                print(e)

            tmpnum +=1
        b = datetime.datetime.now()
        delta = b - a
        print ("Time Used with 1 thread : %d ms" %(int(delta.total_seconds() * 1000)))


def get_image_paths(folder):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if 'jpeg' in f)


if __name__ == '__main__':
	fire.Fire(jresize)
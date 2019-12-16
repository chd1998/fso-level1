#!/usr/bin/python3
import os
from pprint import pprint
import numpy as np
        
def get_image_paths(folder):
    return (os.path.join(folder, f)
            for f in os.listdir(folder)
            if 'fits' in f)

dt = np.dtype([('imagename', np.str,100), ('gpunum', np.int,1),('gpudev',np.int,1)])
paralists = np.zeros((1,),dtype=dt)
images = get_image_paths('./sub')
print(" ")
gpudev = 0
gpunum = 4
i = 0
for image in images:
    paralists = ([image,gpunum,gpudev])
    pprint(paralists)
    paralists.append(paralists)
    gpudev = (gpudev+1) % gpunum
    i = i + 1


'''
sift-cv-xx.py

@author: chen dong @ fso
purposes: sift using cv

Usage: python sift-cv-xx.py input output
Example: python sift-cv-xx.py d:\fso-data\fso-test-data  result.jpg


Changlog:
20190701	Release 0.1		prototype version 

'''

import os
import PIL
import datetime
import numpy as np
import fire
import cv2
import Utility

from PIL import Image
from multiprocessing import Pool
from astropy.io import fits


img1 = cv2.imread('1.jpg')
img2 = cv2.imread('2.jpg')
result,_,_ = Utility.siftImageAlignment(img1,img2)
allImg = np.concatenate((img1,img2,result),axis=1)
cv2.namedWindow('Result',cv2.WINDOW_NORMAL)
cv2.imshow('Result',allImg)
cv2.waitKey(0)
    

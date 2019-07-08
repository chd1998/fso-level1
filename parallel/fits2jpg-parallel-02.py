'''
fits2jpg

@author: chen dong @ fso
purposes: generating the jpeg thumbnails of fits files in source SAVE_DIRECTORY
Note: single --- using 1 thread; parallel --- using specific number of threads via input

Usage: python fits2jpg-xx.py -p <inputpath> --sx <num1> --sy <num2>
Example: python fits2jpg-xx.py -p d:\\fso-test --sx 200 --sy 200

Changlog:
20190701	Release 0.1		prototype version both in single & parallel version
20190705	Release 0.2     revised, add input argvs

'''

import os
import PIL
import datetime
import numpy as np
import sys, getopt

from PIL import Image
from multiprocessing import Pool
from astropy.io import fits

sx = 256
sy = 256
tn = 10 #default threadnumber 10
SIZE = tuple([sx,sy])	#default thumbnail size 256*256
SAVE_DIRECTORY = 'thumbs' #default directory for thumbnail
T_DIR = "."  #default source file(s) directory is current directory

def main(argv):
	sx = 256
	sy = 256
	tn = 10

	try:
		opts, args = getopt.getopt(argv,"hp:p:t:x:y:",["help","input_path=","tn=","sx=","sy="])
	except getopt.GetoptError:
		print ('Usage: python fits2jpg-xx.py -p <inputpath> --tn <num> --sx <num1> --sy <num2> ')
		print ('Example: python fits2jpg-xx.py -p d:\\fso-test --tn 10 --sx 200 --sy 200 ')
		sys.exit(2)
	if(list.__len__(sys.argv) <= 1):
		print ('Usage: python fits2jpg-xx.py -p <inputpath> --tn <num> --sx <num1> --sy <num2> ')
		print ('Example: python fits2jpg-xx.py -p d:\\fso-test --tn 10 --sx 200 --sy 200 ')
		sys.exit(2)
	#print(list.__len__(sys.argv))

	numtmp = 0
	for opt, arg in opts:
		numtmp = numtmp + 1
	if (numtmp != 4):
		print ('Usage: python fits2jpg-xx.py -p <inputpath> --tn <num> --sx <num1> --sy <num2> ')
		print ('Example: python fits2jpg-xx.py -p d:\\fso-test --tn 10 --sx 200 --sy 200 ')
		sys.exit(2)

	for opt, arg in opts:
		if opt == '-h':
			print ('Usage: python fits2jpg-xx.py -p <inputpath> --tn <num> --sx <num1> --sy <num2> ')
			print ('Example: python fits2jpg-xx.py -p d:\\fso-test --tn 10 --sx 200 --sy 200 ')
			sys.exit()
		elif opt in ('-p'):
			T_DIR = arg
		elif opt in ('--tn'):
			tn = int(arg)
		elif opt in ('--sx'):
			sx = arg
		elif opt in ('--sy'):
			sy = arg
		else:
			print ('Usage: python fits2jpg-xx.py -p <inputpath> --sx <num1> --sy <num2> ')
			print ('Example: python fits2jpg-xx.py -p d:\\fso-test --sx 200 --sy 200 ')
			sys.exit()
		SIZE = tuple([sx,sy])
	folder = os.path.realpath(
		T_DIR)

	if not os.path.isdir(os.path.join(folder, SAVE_DIRECTORY)):
		os.makedirs(os.path.join(folder, SAVE_DIRECTORY))

	images = get_image_paths(folder)
	a = datetime.datetime.now()
	pool = Pool(processes=tn)
	print ("Converting...")
	pool.map(create_thumbnail, images)
	pool.close()
	pool.join()
	b = datetime.datetime.now()
	delta = b - a
	print ("Time Used with %d thread : %d ms" %(tn, int(delta.total_seconds() * 1000)))

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
	#im1 = im1.astype(np.int8)
	hud.close()
	#tmp = tmp.astype(np.int32)
	im = Image.fromarray(im1,mode="L")
	im.thumbnail(SIZE, Image.ANTIALIAS)
	#im.resize(SIZE)
	base, fname = os.path.split(filename)
	fname = fname+".jpg"
	save_path = os.path.join(base, SAVE_DIRECTORY, fname)
	print ("Converting %s" %fname)
	im.save(save_path)

if __name__ == '__main__':
	main(sys.argv[1:])

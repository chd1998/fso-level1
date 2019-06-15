# -*- coding: utf-8 -*-
"""
Created on Sat Dec 15 22:08:54 2018
Solar Image Registration （SIR）
@author: jkf

Usage:
python sir-fso-02.py -p <inputpath> -i <inputfile> -d<debug> --sx <num1> --sy <num2> --ex <num3> --ey <num4> -v <videofile> -o<output>
Example:
Python sir-fso-02.py -p d:\data\  -i *.fits -d True --sx 250 --sy 250 --ex 750 --ey 750 -v test.avi -o True


***change log***
2019/02/05:
sir-fso-cuda-01.py:working with cupy(cuda) & modified by chen dong
2019/02/08:
sir-fso-01.py:working without cuda & modifiied by chen dong
2019/06/14:
2019/06/14
sir-fso-02.py: revised
sir-fso-cuda-02.py:revised
"""

import sys, getopt
import numpy as np
import glob
import time
import astropy.io.fits as fits
import cv2
import matplotlib as mp
import matplotlib.patches as patches
import matplotlib.pyplot as plt
#import tools
import platform
#import cupy as cp
import scipy.fftpack as fft
from sys import argv

#全局变量
input_path = '.'  # 默认序列图像目录为当前
input_file = '*.fits'  # 文件名，支持*通配符
left = [250, 250]  # 选择配准区域的开始坐标，默认250,250
right = [750, 750]  # 配准区域的结束坐标,默认750,750  如果不输入这些坐标值，将自动选取整个图像的中心四分之一区域作为配准区域
videoname = 'test.avi'  # 默认输出的视频文件名，目录为当前目录，如果不输入，则不产生视频
displayimage = True  # 在配准中是否显示动态图像，缺省是TRUE
createfile = False  # 是否产生配准后的fits 文件，如果产生，将在数据目录下产生一个sir文件夹。 缺省是False
sys_sep = '\\' #默认windows系统
debug = False ##打印debug信息，默认是False

def main(argv):
	sx = 250
	sy = 250
	ex = 750
	ey = 750

	try:
		opts, args = getopt.getopt(argv,"hp:i:d:v:o:",["help","input_path=","input_file=","sx=","sy=","ex=","ey=","videofile=","output="])
	except getopt.GetoptError:
		print ('python sir-fso.py -p <inputpath> -i <inputfile> -d<debug> --sx <num1> --sy <num2> --ex <num3> --ey <num4> -v <videofile> -o<output>')
		sys.exit(2)
	if(list.__len__(sys.argv) <= 1):
		print ('python sir-fso.py -p <inputpath> -i <inputfile> -d<debug> --sx <num1> --sy <num2> --ex <num3> --ey <num4> -v <videofile> -o<output>')
		sys.exit(2)
	#print(list.__len__(sys.argv))
	for opt, arg in opts:
		if opt == '-h':
			print ('python sir-fso.py -p <inputpath> -i <inputfile> -d<debug> --sx <num1> --sy <num2> --ex <num3> --ey <num4> -v <videofile> -o<output>')
			sys.exit()
		elif opt in ('-p'):
			input_path = arg
		elif opt in ('-i'):
			input_file = arg
		elif opt in ('-d'):
			debug = arg
		elif opt in ('--sx'):
			sx = arg
		elif opt in ('--sy'):
			sy = arg
		elif opt in ('--ex'):
			ex = arg
		elif opt in ('--ey'):
			ey = arg
		elif opt in ('-v'):
			videoname = arg
		elif opt in ('-o'):
			createfile = arg
		else:
			print ('python sir-fso.py -p <inputpath> -i <inputfile> --sx <num1> --sy <num2> --ex <num3> --ey <num4> -v <videofile> -o')
			sys.exit()

	sx = np.int32(sx)
	sy = np.int32(sy)
	ex = np.int32(ex)
	ey = np.int32(ey)
	left = [sx,sy]
	right = [ex,ey]
	local_sys = platform.system()
	if local_sys == 'Linux':
	 	sys_sep = '/'
	else:
	 	sys_sep = '\\'
	print ("input file :",input_file)
	print ("input path :",input_path)
	print ("start point :",left)
	print ("end point :",right)
	print ("video name :",videoname)
	print ("create file :",createfile)
	#print("Using CUDA device: ",cp.cuda.Device().id)
	dxy = sir_main(input_path + sys_sep, sys_sep, input_file, left,right,disflag=displayimage, fileflag=createfile, videoname=videoname)
	plt.figure('Subpix shift - without cuda')
	plt.plot(dxy[:, 0])
	plt.plot(dxy[:, 1])
	plt.figure('Correlation - without cuda')
	plt.plot(dxy[:, 2])
	plt.show()
	sys.exit(0)

def sir_main(dirn, sys_sep, filen, left=[0, 0], right=[0, 0], disflag=True, fileflag=False, videoname=None):
		plt.close('Sir 3.0 - without cuda')
		plt.close('Subpix shift - with cuda')
		plt.close('Correlation - with cuda')
		total_time = 0.0

		filename = glob.glob(dirn + sys_sep + filen)
		dirnlen = len(dirn)

		out_dir = dirn + 'sir' + sys_sep

		if fileflag: mkdir(out_dir)

		data0 = (fits.getdata(filename[0])).astype(float)
		im0 = removenan(np.squeeze(data0))
		dxy = []
		dis_s_pix = np.array([0, 0])
		dis_s_subpix = np.array([0, 0])
		H, W = im0.shape

		if left == [0, 0] or right == [0, 0]:
				left[0] = W // 4
				left[1] = H // 4
				right[0] = (W * 3) // 4
				right[1] = (H * 3) // 4

		if left[0] < 0 or left[0] > (W - 1): left[0] = 0
		if left[1] < 0 or left[1] > (H - 1): left[1] = 0
		if right[0] > (W - 1) or right[0] < 0: right[0] = W - 1
		if right[1] > (H - 1) or right[1] < 0: right[1] = H - 1

		X = (np.arange(left[0], right[0]))
		Y = (np.arange(left[1], right[1]))

		mtmp = imgcut(im0, X, Y)
		mx = np.minimum(mtmp.mean() + 3 * mtmp.std(), mtmp.max())
		mi = np.maximum(mtmp.mean() - 3 * mtmp.std(), mtmp.min())

		if videoname is not None:

				Cim = np.zeros((H, W, 3)).astype(np.uint8)
				video = cv2.VideoWriter(videoname, cv2.VideoWriter_fourcc('M', 'J', 'P', 'G'), 5.0, (W, H))

		K = 0
		for i in range(len(filename)):

				start = time.process_time()
				header = fits.getheader(filename[i])
				data0 = (fits.getdata(filename[i])).astype(float)
				im = removenan(np.squeeze(data0))

				#        if i==5:im=tools.circshift(im,1000,1000)

				c_subpix, dis_s_subpix, dis_s_pix, sub, cor = align_all(im0, im, dis_s_pix, dis_s_subpix, X, Y)

				#if cor > 0.7:
				#		im0 = im

				dxy.append(list(np.hstack((dis_s_subpix, cor))))

				if fileflag:
						outfile = out_dir + 'sir_' + filename[i][dirnlen:]
						print(outfile)
						fits.writeto(outfile, c_subpix, header, output_verify='fix', overwrite=True, checksum=False)

				if disflag:
						plt.figure('Sir 3.0 - with cuda')

						if K == 0:
								dis = plt.imshow(c_subpix, vmin=mi, vmax=mx, cmap='gray')
								plt.pause(0.01)
#                plt.show()
						else:
								dis.set_data(c_subpix)
						K = 1

						currentAxis = plt.gca()
						rect = patches.Rectangle((left[0], left[1]), right[0] - left[0], right[1] - left[1], linewidth=1,
																		 edgecolor='r', facecolor='none')
						currentAxis.add_patch(rect)

						plt.grid(True, linestyle="-.", color="w", linewidth="1")
						plt.title(filename[i])
						plt.pause(0.01)
#            plt.show()

				if videoname != None:
						for j in range(0, 3):
								Cim[:, :, j] = (imnorm(c_subpix, mx, mi) * 255).astype(int)
						video.write(Cim)

				end = time.process_time()
				total_time = total_time + (end-start)
				pstr = ('id:%5d   dx=%7.2f   dy=%7.2f   corr=%7.2f Runtime=%7.2f  %s' % (
				i, dis_s_subpix[0], dis_s_subpix[1], cor, end - start, filename[i][dirnlen:]))

				if cor < 0.7:
						print("\033[1;31;40m" + pstr + "\033[0m")
				else:
						print(pstr)

		if videoname is not None:
				cv2.destroyAllWindows()
				video.release()

		dxy = np.array(dxy)
		print('Total time used without cuda: %7.2f seconds...'%total_time)
		return dxy

def align_all(s_org, c_org, dis_s_pix, dis_s_subpix, X, Y):
	try:
		pix_x, pix_y, cor = align_pix(s_org, c_org, X, Y)
		#print("1")
		#print (cor)
		if cor < 0.7:
			return c_org, dis_s_subpix, dis_s_pix, np.array([0, 0]), cor
		dis_c_pix = np.array([pix_x, pix_y])
		#print("here")
		c_pix = circshift(c_org, dis_c_pix[0], dis_c_pix[1])
		#print("here")
		X = X[pix_x:] if pix_x >= 0 else X[:pix_x - 1]
		Y = Y[pix_y:] if pix_y >= 0 else Y[:pix_y - 1]
		#print("here")
		sub_x, sub_y, cors, T1, T2 = align_subpix(s_org, c_pix, X, Y)
		#print("here")
		c_subpix = np.array([sub_x, sub_y]) + dis_c_pix
		#print("here")
		dis_c_subpix = c_subpix #+ dis_s_subpix
		#print(dis_c_subpix[0], dis_c_subpix[1])
		c_subpix = immove(c_org, dis_c_subpix[0], dis_c_subpix[1]).astype('float32')
		#print("here")
	except:
		print("\033[1;31;40m"+'Err in align_all routine'+"\033[0m")
		sys.exit()
	if debug: print('pix   :%f %f %f' % (pix_x, pix_y, cor))
	return c_subpix, dis_c_subpix, dis_c_pix, c_subpix, cor

def align_subpix(A, B, X, Y):
		# 亚象元对齐
		try:
				R0 = 2
				# 得到子图
				standimage = imgcut(A, X, Y)
				compimage = imgcut(B, X, Y)
				M, N = standimage.shape
				L = np.array([600, M, N]).min()

				T1, T2 = M // L, N // L

				M0, N0, k = L, L, 0
				ci, si = [], []
				for i in range(T1):
						for j in range(T2):
								si.append(standimage[i * M0:(i + 1) * M0, j * N0:(j + 1) * N0])
								ci.append(compimage[i * M0:(i + 1) * M0, j * N0:(j + 1) * N0])
								k += 1

				# 建立窗函数

				TT = T1 * T2
				mi = np.empty(TT)
				ni = np.empty(TT)
				cor = np.empty(TT)


				for i in range(TT):
						mi[i], ni[i], cor[i] = xcorrcenter(si[i], ci[i], R0, 0)
						#print("align_subpix")
				#
				if debug:
						pstr = ('%f %f %f %f %f %d %d\n' % (mi.mean(), mi.std(), ni.mean(), ni.std(), cor.mean(), T1, T2))
						print(pstr)

				id = cor.argsort()[::-1]
				if TT > 1:
						W = cor[id[0]] + cor[id[1]]
						m = mi[id[1]] * cor[id[1]] + mi[id[0]] * cor[id[0]]
						m /= W
						n = ni[id[1]] * cor[id[1]] + ni[id[0]] * cor[id[0]]
						n /= W
						W /= 2
				else:
						m, n, W = mi[0], ni[0], cor[0]
		except:
				m, n, W, T1, T2 = 0, 0, 0, 0, 0

		return m, n, W, T1, T2


def align_pix(A, B, X, Y):
		# 象元级对齐，使用迭代
		try:
				R0 = 2
				# 得到子图
				standimage = np.copy(A)
				compimage = np.copy(B)
				M, N = standimage.shape
				# 建立窗函数

				# 对齐整数象元
				# 得到整数偏移量

				dx, dy = 1, 0
				ddx, ddy = 0, 0
				i = 0

				while ((abs(dx) > 0 or abs(dy) > 0) and (i <= 20)):  # 迭代
						i = i + 1

						X = X[dx:] if dx >= 0 else X[:dx - 1]
						Y = Y[dy:] if dy >= 0 else Y[:dy - 1]
						#print("1")
						m, n, cor = xcorrcenter(imgcut(standimage, X, Y), imgcut(compimage, X, Y), R0, 0)
						#print("2")
						dx = np.ceil(m - 0.5).astype(int)
						dy = np.ceil(n - 0.5).astype(int)

						# 移动整数象元
						compimage = circshift(compimage, dx, dy)
						ddx += dx
						ddy += dy
		except:
				ddx, ddy, cor = 0, 0, 0
				print("\033[1;31;40m"+'Err in align_pix routine!'+"\033[0m")

		return ddx, ddy, cor


def corrwin(M, N):
		w = 1
		return w


def xcorrcenter(standimage, compimage, R0, flag):
	# if flag==1,standimage 是FFT以后的图像，这是为了简化整数象元迭代的运算量。直接输入FFT以后的结果，不用每次都重复计算
	try:
		M, N = standimage.shape
		standimage = zscore2(standimage)
		compimage = zscore2(compimage)
		im = np.ndarray((M,N),dtype=np.complex64)
		s = fft.fft2(standimage)
		c = np.fft.ifft2(compimage)
		sc = s * c
		im = np.abs(fft.fftshift(fft.ifft2(sc)))  # /(M*N-1);%./(1+w1.^2);
		#print("Using GPU")
		'''
		cp.cuda.Device(0).use()
		with cp.cuda.Device(0):
			s_gpu = cp.ndarray((M,N),dtype=np.complex64)
			c_gpu = cp.ndarray((M,N),dtype=np.complex64)
			sc_gpu = cp.ndarray((M,N),dtype=np.complex64)
			s_gpu = cp.asarray(standimage)
			c_gpu = cp.asarray(compimage)
			s_gpu = cp.fft.fft2(s_gpu)
			c_gpu = cp.fft.ifft2(c_gpu)
		#print("calculating image for comparison...")
			sc_gpu = s_gpu * c_gpu
			sc_gpu = cp.fft.ifft2(sc_gpu)
		#print("calculating product of 2 images...")
			sc_gpu = cp.abs(cp.fft.fftshift(sc_gpu))
		im = cp.asnumpy(sc_gpu)
		'''
		#print("GPU ended!")
		cor = im.max()
		if cor == 0:
			return 0, 0, 0


		M0, N0 = np.where(im == cor)
		m, n = M0[0], N0[0]

		if flag:
			m -= M / 2
			n -= N / 2
			# 判断图像尺寸的奇偶
			if np.mod(M, 2): m += 0.5
			if np.mod(N, 2): n += 0.5
			return m, n, cor

		# 求顶点周围区域的最小值
		immin = im[(m - R0):(m + R0 + 1), (n - R0):(n + R0 + 1)].min()
		# 减去最小值
		im = np.maximum(im - immin, 0)
		# 计算重心
		x, y = np.mgrid[:M, :N]
		area = im.sum()
		m = (np.double(im) * x).sum() / area
		n = (np.double(im) * y).sum() / area
		# 归算到原始图像
		m -= M / 2
		n -= N / 2
		# 判断图像尺寸的奇偶
		if np.mod(M, 2): m += 0.5
		if np.mod(N, 2): n += 0.5
	except:
		print("\033[1;31;40m"+'Err in align_Subpix routine!'+"\033[0m")
		m, n, cor = 0, 0, 0
	return m, n, cor
#
def imnorm(im, mx=0, mi=0):
    #   图像最大最小归一化 0-1
    if mx != 0 and mi != 0:
        pass
    else:
        mi, mx = np.min(im), np.max(im)

    im2 = removenan((im - mi) / (mx - mi))

    arr1 = (im2 > 1)
    im2[arr1] = 1
    arr0 = (im2 < 0)
    im2[arr0] = 0

    return im2


def imgcut(A, X, Y):
    """
    get subimage
    A: image narray
    X,Y: narray [2,3,4,5,.....100]
    """
    try:
        B = A[X[0]:X[-1], Y[0]:Y[-1]]
    except:
        B = A
        print('Warning:ROI is out of Image range. Whole image is selected as ROI')

    return B


def zscore2(im):
    """
    归一化：均值为0，方差为1
    """
    st = im.std()
    if st > 0:
        im = removenan((im - im.mean()) / im.std())
    else:
        im = removenan(im - im.mean())

    return im


def immove(image, dx, dy):
    """
    image shift by subpix
    """
    # The shift corresponds to the pixel offset relative to the reference image
    """
    from scipy.ndimage import fourier_shift
    if dx == 0 and dy == 0:
        offset_image = image
    else:
        shift = (dx, dy)
        M, N = image.shape
        gpu_image = cp.ndarray((M,N),dtype=np.complex64)
        gpu_image = cp.asarray(image)
        gpu_image = cp.fft.fft2(gpu_image)
        fft_image = cp.asnumpy(gpu_image)
        tmp_image = fourier_shift(fft_image, shift)
        gpu_image = cp.asarray(tmp_image)
        gpu_image = cp.fft.ifft2(gpu_image)
        offset_image = cp.asnumpy(gpu_image)
        offset_image = np.real(offset_image)
    """
    from scipy.ndimage import fourier_shift
    if dx == 0 and dy == 0:
        offset_image = image
    else:
        shift = (dx, dy)
        offset_image = fourier_shift(fft.fft2(image), shift)
        offset_image = np.real(fft.ifft2(offset_image))

    return offset_image

    return offset_image


def removenan(im, key=0):
    """
    remove NAN and INF in an image
    """
    im2 = np.copy(im)
    arr = np.isnan(im2)
    im2[arr] = key
    arr2 = np.isinf(im2)
    im2[arr2] = key

    return im2


def circshift(im, dx=0, dy=0):
    """
    shift an image by pixels
    """
    im1 = im.copy()
    if dx != 0:  im1 = np.roll(im1, dx, axis=0)
    if dy != 0:  im1 = np.roll(im1, dy, axis=1)

    return im1


def mkdir(path):
    # 引入模块
    import os

    path = path.strip()
    # 去除尾部 \ 符号
    path = path.rstrip(sys_sep)

    # 判断路径是否存在
    isExists = os.path.exists(path)

    # 判断结果
    if isExists:
        return False
    else:
        os.makedirs(path)
        return True

'''
def cc1d(standspe,compspe):
    M = len(standspe)

    standspe = (standspe-standspe.mean())/standspe.std()
    s = fft.fft(standspe)

    compspe = (compspe-compspe.mean())/compspe.std()
    c = fft.ifft(compspe)

    sc = s * c
    im = np.abs(fft.ifft(sc))  # /(M*N-1);%./(1+w1.^2);
    cor = im.max()
    M0 = np.where(im == cor)
    m=np.int(M0[0])
    if m>M/2:m=m-M
            # 判断图像尺寸的奇偶
    return m,  cor

def alignspe_pix(A, B):


    standspe = np.copy(A)
    compspe = np.copy(B)

    dx,ddx,i = 1,0,0

    while (abs(dx) > 0  and (i <= 20)):  # 迭代
        i = i + 1
        if dx >=0 :
            standspe=A[ddx:]
            compspe=B[ddx:]
        else:
            standspe=A[:ddx-1]
            compspe=B[:ddx-1]

        dx, cor = cc1d(standspe, compspe)


        # 移动整数象元

        ddx += dx

        B = circshift(B, dx)
 '''
def smallmatchlarge(im,im0):
    import cv2
    res = cv2.matchTemplate(im,im0,cv2.TM_CCOEFF_NORMED)
    min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(res)
    left = max_loc
    return left,max_val


if __name__ == "__main__":
	main(sys.argv[1:])

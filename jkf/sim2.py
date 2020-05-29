# -*- coding: utf-8 -*-
"""
Created on Sat Nov 24 16:05:28 2018

@author: jkf
pip install opencv-contrib-python==3.4.2.16
"""

#import cv2
import matplotlib.pyplot as plt
import numpy as np
from skimage.transform import warp, EuclideanTransform,SimilarityTransform, rotate,rescale
from skimage import transform
import scipy.fftpack as fft
import cupy as cp



def fitswrite(fileout, im, header=None):
    from astropy.io import fits
    import os
    if os.path.exists(fileout):
        os.remove(fileout)
    if header is None:
        fits.writeto(fileout, im, output_verify='fix', overwrite=True, checksum=False)
    else:        
        fits.writeto(fileout, im, header, output_verify='fix', overwrite=True, checksum=False)


def fitsread(filein):
    from astropy.io import fits
    head = '  '
    hdul = fits.open(filein)

    try:
        data0 = hdul[0].data.astype(np.float32)
        head = hdul[0].header
    except:
        hdul.verify('silentfix')
        data0 = hdul[1].data
        head = hdul[1].header

    return data0, head

def removelimb(im, center=None, RSUN=None):
  #  pip install polarTransform
    import polarTransform as pT
    from scipy import signal

    radiusSize, angleSize = 1024, 1800
    im = removenan(im)
    im2=im.copy()
    if center is None:
        T = (im.max() - im.min()) * 0.2 + im.min()
        arr = (im > T)
        import scipy.ndimage.morphology as snm
        arr=snm.binary_fill_holes(arr)
#        im2=(im-T)*arr
        Y, X = np.mgrid[:im.shape[0], :im.shape[1]]
        xc = (X * arr).astype(float).sum() / (arr*1).sum()
        yc = (Y * arr).astype(float).sum() / (arr*1).sum()
        center = (xc, yc)
        RSUN = np.sqrt(arr.sum() / np.pi)

    Disk = np.int8(disk(im.shape[0], im.shape[1], RSUN * 0.95))
    impolar, Ptsetting = pT.convertToPolarImage(im, center, radiusSize=radiusSize, angleSize=angleSize)
    profile = np.median(impolar, axis=0)
    profile = signal.savgol_filter(profile, 11, 3)
    Z = profile.reshape(-1, 1).T.repeat(impolar.shape[0], axis=0)
#    im2 = removenan(im / Ptsetting.convertToCartesianImage(Z))-1
#    im2 = im2 * Disk
    im = removenan(im -Ptsetting.convertToCartesianImage(Z))
    im= im*Disk
    return im, center, RSUN, profile,Z


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


def showim(im):
    mi = np.max([im.min(), im.mean() - 3 * im.std()])
    mx = np.min([im.max(), im.mean() + 3 * im.std()])
    if len(im.shape) == 3:
        plt.imshow(im, vmin=mi, vmax=mx)
    else:
        plt.imshow(im, vmin=mi, vmax=mx, cmap='gray',interpolation='bicubic')

    return


def zscore2(im):
    im = (im - np.mean(im)) / im.std()
    return im


def disk(M, N, r0):
    X, Y = np.meshgrid(np.arange(int(-(N / 2)), int(N / 2)), np.linspace(-int(M / 2), int(M / 2) - 1, M))
    r = (X) ** 2 + (Y) ** 2
    r = (r ** 0.5)
    im = r < r0
    return im


#def fgauss(M, N, I, x0, y0, r):
#    # 产生高斯图像
#
#    r = r * r * 2
#    x = np.arange(0, M)
#    x = x - M / 2 + x0 - 1
#    y = np.arange(0, N)
#    y = y - N / 2 + y0 - 1
#    w1 = np.exp(-x ** 2 / r)
#    w2 = np.exp(-y ** 2 / r)
#    w2 = np.reshape(w2, (-1, 1))
#    f = I * w1 * w2
#    return f
#
#
#def showmesh(im):
#    X, Y = np.mgrid[:im.shape[0], :im.shape[1]]
#    from mpl_toolkits.mplot3d import Axes3D
#    figure = plt.figure('mesh')
#    axes = Axes3D(figure)
#
#    axes.plot_surface(X, Y, im, cmap='rainbow')
#    return


def create_gif(images, gif_name, duration=1):
    import imageio
    frames = []
    # Read
    T = images.shape[2]
    for i in range(T):
        frames.append(np.uint8(imnorm(images[:, :, i]) * 255))
    #    # Save
    imageio.mimsave(gif_name, frames, 'GIF', duration=duration)

    return


def immove2(im,dx=0,dy=0):
    im2,para=array2img(im)
    tform = SimilarityTransform(translation=(dx,dy))
    im2 = warp(im2, tform.inverse, output_shape=(im2.shape[0], im2.shape[1]),mode='reflect')
    im2=img2array(im2,para)
    return im2



def imcenterpix(im):
    X0=(im.shape[0])//2
    Y0=(im.shape[1])//2
    cen=(X0,Y0)
    return cen



def xcorrcenter(standimage, compimage, R0=3, flag=0):
    # if flag==1,standimage 是FFT以后的图像，这是为了简化整数象元迭代的运算量。直接输入FFT以后的结果，不用每次都重复计算
    try:
        M, N = standimage.shape

        standimage = zscore2(standimage)
        s = fft.fft2(standimage)

        compimage = zscore2(compimage)
        c = np.fft.ifft2(compimage)

        sc = s * c
        im = np.abs(fft.fftshift(fft.ifft2(sc)))  # /(M*N-1);%./(1+w1.^2);
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
        print('Err in align_Subpix routine!')
        m, n, cor = 0, 0, 0
    return m, n, cor
def cc(standimage, compimage, flag=0,win=1):
 
        M, N = standimage.shape
        if flag==0:
            standimage = zscore2(standimage)
            s = fft.fft2(standimage)
        else:    
            s=standimage
            
        c = zscore2(compimage)
        c=compimage
        c = fft.fft2(c)
    
        sc = s * np.conj(c)*win
        im = np.abs(fft.fftshift(fft.ifft2(sc)))  # /(M*N-1);%./(1+w1.^2);
#        im=im/(im.shape[0]*im.shape[1])
        cor = im.max()
        if cor == 0:
            return 0, 0, 0

        M0, N0 = np.where(im == cor)
        m, n = M0[0], N0[0]

        m -= M / 2
        n -= N / 2
        # 判断图像尺寸的奇偶
        if np.mod(M, 2): m += 0.5
        if np.mod(N, 2): n += 0.5

        c=np.abs(c)

        return m, n, cor,c
    
        # 求顶点周围区域的最小值




def immove(image, dx, dy):
    """
    image shift by subpix
    """
    # The shift corresponds to the pixel offset relative to the reference image
    from scipy.ndimage import fourier_shift
    if dx == 0 and dy == 0:
        offset_image = image
    else:
        shift = (dx, dy)
        offset_image = fourier_shift(fft.fft2(image), shift)
        offset_image = np.real(fft.ifft2(offset_image))

    return offset_image

def combin_img(z,Ncol):
    import numpy as np
    Nrow=z.shape[0]//Ncol

    for i in range(Ncol):
        for j in range(Nrow):
            if j==0:
                row=(z[j+i*Nrow])
            else:
                row=np.hstack((row,z[j+i*Nrow]))
        if i==0:        
            col=row
        else:
            col=np.vstack((col,row))
    return col

def rebin(arr, nbin):

    m=arr.shape[0]//nbin
    n=arr.shape[1]//nbin
    shape = (m, nbin,n, nbin)
    return arr.reshape(shape).sum(-1).sum(1)

def showmesh(im,flag=0):
#    x=np.arange(0,im.shape[0])
#    y=np.arange(0,im.shape[1])
    X,Y=np.mgrid[:im.shape[0],:im.shape[1]]
    from mpl_toolkits.mplot3d import Axes3D
    figure = plt.figure('mesh '+str(flag))
    axes = Axes3D(figure)
#    plt.show()
    axes.plot_surface(X,Y,im,cmap='rainbow')
    return  

def cc_gpu(standimage, compimage, flag=0):
	# if flag==1,standimage 是FFT以后的图像，这是为了简化整数象元迭代的运算量。直接输入FFT以后的结果，不用每次都重复计算
        M, N = standimage.shape
        if cp.cuda.Device(0):
            cp.cuda.Device(0).use()
            if flag==0:
                standimage = zscore2(standimage)

#                s_gpu = cp.ndarray((M,N),dtype=np.complex64)
                s_gpu = cp.asarray(standimage)
                s_gpu = cp.fft.fft2(s_gpu)
            else:
                s_gpu=standimage.copy()
            #im = np.ndarray((M,N),dtype=np.complex64)

            #prepare 3 arrays on gpu
            compimage = zscore2(compimage)
            # c_gpu = cp.ndarray((M,N),dtype=np.complex64)
            # sc_gpu = cp.ndarray((M,N),dtype=np.complex64)
            #copy images from host to gpu
            
            c_gpu = cp.asarray(compimage)
            c_gpu = cp.fft.ifft2(c_gpu)
            
            sc_gpu = cp.multiply(s_gpu,c_gpu)
            sc_gpu = cp.fft.ifft2(sc_gpu)
            
            sc_gpu = cp.abs(cp.fft.fftshift(sc_gpu))     
            im = cp.asnumpy(sc_gpu)
        else:

            if flag==0:
                standimage = zscore2(standimage)
                s = fft.fft2(standimage)
            else:    
                s=standimage.copy()
                
                c = zscore2(compimage)
                c = np.fft.ifft2(c)
        
                sc = s * c
                im = np.abs(fft.fftshift(fft.ifft2(sc)))  # /(M*N-1);%./(1+w1.^2) 
    		#print("GPU ended!")
        cor = im.max()
        if cor == 0:
            return 0, 0, 0


        M0, N0 = np.where(im == cor)
        m, n = M0[0], N0[0]

	
        m -= M / 2
        n -= N / 2
		# 判断图像尺寸的奇偶
        if np.mod(M, 2): m += 0.5
        if np.mod(N, 2): n += 0.5
        
        
        return m, n, cor 
    
def gc_gpu(standimage, compimage, flag=0):
	# if flag==1,standimage 是FFT以后的图像，这是为了简化整数象元迭代的运算量。直接输入FFT以后的结果，不用每次都重复计算
        M, N = standimage.shape
        if cp.cuda.Device(0):
            cp.cuda.Device(0).use()
            if flag==0:
                standimage = zscore2(standimage)

#                s_gpu = cp.ndarray((M,N),dtype=np.complex64)
                s_gpu = cp.asarray(standimage)
                s_gpu = cp.fft.fft2(s_gpu)
            else:
                s_gpu=standimage.copy()
            #im = np.ndarray((M,N),dtype=np.complex64)

            #prepare 3 arrays on gpu
            compimage = zscore2(compimage)
            # c_gpu = cp.ndarray((M,N),dtype=np.complex64)
            # sc_gpu = cp.ndarray((M,N),dtype=np.complex64)
            #copy images from host to gpu
            
            c_gpu = cp.asarray(compimage)
            c_gpu = cp.fft.ifft2(c_gpu)
            
            sc_gpu = cp.multiply(s_gpu,c_gpu)
            sc_gpu=sc_gpu/cp.abs(sc_gpu)
            sc_gpu = cp.fft.ifft2(sc_gpu)
            
            sc_gpu = cp.abs(cp.fft.fftshift(sc_gpu))     
            im = cp.asnumpy(sc_gpu)
        else:

            if flag==0:
                standimage = zscore2(standimage)
                s = fft.fft2(standimage)
            else:    
                s=standimage.copy()
                
                c = zscore2(compimage)
                c = np.fft.ifft2(c)
        
                sc = s * c
                sc=sc/np.abs(sc)
                im = np.abs(fft.fftshift(fft.ifft2(sc)))  # /(M*N-1);%./(1+w1.^2) 
    		#print("GPU ended!")
        cor = im.max()
        if cor == 0:
            return 0, 0, 0


        M0, N0 = np.where(im == cor)
        m, n = M0[0], N0[0]

	
        m -= M / 2
        n -= N / 2
		# 判断图像尺寸的奇偶
        if np.mod(M, 2): m += 0.5
        if np.mod(N, 2): n += 0.5
        
        
        return m, n, cor  
def makeGaussian(size, sigma = 3, center=None):

    x = np.arange(0, size, 1, float)
    y = x[:,np.newaxis]

    if center is None:
        x0 = y0 = size // 2
    else:
        x0 = center[0]
        y0 = center[1]

    return np.exp(-4*np.log(2) * ((x-x0)**2 + (y-y0)**2) / sigma**2)   

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
def imshift(im,translation=[0,0]):

    # tform = EuclideanTransform(translation=translation)
    # im = warp(im2, tform.inverse, output_shape=(im2.shape[0], im2.shape[1]),mode='reflect')

    """
    shift an image by pixels
    """
    translation=(np.array(translation)).astype('int')
    im1 = im.copy()
    im1 = np.roll(im1, translation[0], axis=0)
    im1 = np.roll(im1, translation[1], axis=1)
    return im1  

def imrotate(im,para):
    return rotate(im,pare,mode='reflect')

def imresize(im,para):
    return resize(im,para,mode='reflect')

def imrescale(im,size):
    return rescale(im,para,mode='reflect')

def imtransform(im,scale=1,rot=0,translation=[0,0]):
    im2=im.copy()
    tform = SimilarityTransform(translation=translation)
    im2 = warp(im2, tform.inverse, output_shape=(im2.shape[0], im2.shape[1]),mode='reflect')

    im2=rotate(im2,rot,mode='reflect')
    im2=rescale(im2,scale,mode='reflect')

    return im2   

def mkdir(path):    # 引入模块
    import os

    path = path.strip()
    # 去除尾部 \ 符号
    path = path.rstrip("\\")

    # 判断路径是否存在
    isExists = os.path.exists(path)

    # 判断结果
    if isExists:
        return False
    else:
        os.makedirs(path)
        return True
    
def ring_window(N):

    x = np.arange(0, N, 1, float)
    y = x[:,np.newaxis]
    
    window = np.exp(-(np.sqrt((x - N // 2) ** 2 + (y - N // 2) ** 2) - N // 5) ** 2 / (0.02 * N * N))
    return window 

def polpow(im0,order=1):
  #  pip install polarTransform
    import polarTransform as pT

    m=im0.shape[0]//2
    impolar, Ptsetting = pT.convertToPolarImage(im0,finalRadius=m,radiusSize=m, angleSize=360,order=order)
    profile = np.median(impolar, axis=0)

    return profile,impolar
   
def R_tukey(width,alpha=0.5):
  #  pip install polarTransform
    import polarTransform as pT
    from scipy import signal
    profile=signal.windows.tukey(width,alpha)[width//2:]   
    z = profile.reshape(1,-1).repeat(360, axis=0)

    im=pT.convertToCartesianImage(z)
    return im[0]   

def R_tukey2(width,alpha=0.5):
  #  pip install polarTransform
    import polarTransform as pT
    from scipy import signal
    profile=signal.windows.tukey(width,alpha)  
    
    im=np.dot(profile.reshape(-1,1),profile.reshape(1,-1))

    return im  

def H_tukey(width,alpha=0.5):

    from scipy import signal
    profile=signal.windows.tukey(width,alpha)   
    z = profile.reshape(1,-1).repeat(width, axis=0)

    im=z*rotate(z,60)*rotate(z,120)
    return im   
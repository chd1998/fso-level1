# -*- coding: utf-8 -*-
"""
Created on Sat May  2 18:57:15 2020

@author: jkf
"""

#%%%%光球分块选帧拼接重建 for Onset
#%%%%%%%%%季凯帆 2015,1,10--------
#%INPUT  z， 用load调用的三维图像矩阵
#
#%
#%BESTone: 最好的一帧
#%avgZ： 全局选帧重建结果
#
#%NEW： 分块选帧重建的结果
#%NEW_DEConv: 退卷积的结果



#%%%%%%%%%%%%%%%%%%%参数表
import os
#namesub=os.path.basename(file) 
#from skimage.transform import warp, EuclideanTransform

from matplotlib import pyplot as plt
import jkf.sim as sim
import numpy as np
import glob
#import scipy.fftpack as fft
import cupy as cp
sc=5 #最后需要选取的帧数

W=200 #长宽的分块大小  
border=5 #重叠边界宽度
maxdxy=10 #估计的最大位移量
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
def AG(Z):
        z=Z.copy()
        T0=(z.shape[0]-1)//10
        R=np.zeros(z[0].shape)
        C=np.zeros(z[0].shape)
        tmp=np.zeros(z.shape[0])
        for i in range(1,z.shape[0]-1):
            R[:-1,:]=np.diff(z[i],axis=0)
            C[:,:-1]=np.diff(z[i],axis=1)
            tmp[i-1]=(R**2+C**2).mean()
        zid=np.argsort(tmp) 
        sz=z[zid[-T0:]]
        z=np.vstack((z[0][np.newaxis,:],sz))
        z0=sim.zscore2(z[0])
        s_gpu = cp.ndarray(z0.shape,dtype=np.complex64)
        s_gpu = cp.asarray(z0)
        s_gpu = cp.fft.fft2(s_gpu)

        for i in range(1,z.shape[0]):
            dy,dx,cor=sim.cc_gpu(s_gpu,z[i],1)  #位移
#            print(dy,dx,cor)
            if np.abs(dy)<maxdxy and np.abs(dx)<maxdxy:
                z[i]=imshift(z[i],[dy,dx])

        return z[1:].mean(axis=0)    


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#% 


dirnm='E:\\data\\短曝光-光球\\'
filenm='*.fits'
filelist=sorted(glob.glob(dirnm+filenm))
tot=len(filelist)

n0=3104 #原始图像尺寸
m0=2720



blockx=m0//W #可分割的块数
blocky=n0//W
m=blockx*W #实际处理的尺寸
n=blocky*W
dn=round((n0-n)/2) #扣除的边框
dm=round((m0-m)/2)
#X0=np.arange(dm,m+dm) #实际处理的区域
#Y0=np.arange(dn,n+dn)

t=tot

z=[]

for i in range(t):
    file =filelist[i]
    tmp=sim.fitsread(file)[0]
    z.append(tmp[dm:m+dm,dn:n+dn])
z=np.array(z)

print('finished read data')
#z 为三维数据矩阵，一帧代表一个时刻的图像 ！！！！！！！！！！！！！！ 




#%%%%%%%%%%%%%整幅对齐
l,m,n=z.shape
width=m//4 #对齐标准区域的半宽度


firstim=np.double(z[0,m//2-width:m//2+width,n//2-width:n//2+width])

# ffirstim=fft.fft2(sim.zscore2(firstim))
firstim = sim.zscore2(firstim)

s_gpu = cp.ndarray(firstim.shape,dtype=np.complex64)
s_gpu = cp.asarray(firstim)
s_gpu = cp.fft.fft2(s_gpu)
z[0]=(z[0]/z[0].mean()*10000)

for i in range(1,l):
    
    # dy,dx,cor=sim.cc(firstim,z[i,m//2-width:m//2+width,n//2-width:n//2+width],0) #相对于第一帧的偏移量
    
    # tmp=imshift(z[i],[dx,dy])#选取中心区，并进行整数象元对齐
    # z[i]=tmp
    # print(i,dy,dx,cor)
#    z[i,m//2-width:m//2+width,n//2-width:n//2+width]=imshift(firstim,[8,-10])
    dy,dx,cor=sim.cc_gpu(s_gpu,z[i,m//2-width:m//2+width,n//2-width:n//2+width],1) #相对于第一帧的偏移量
    
    tmp=imshift(z[i],[dy,dx])#选取中心区，并进行整数象元对齐
    z[i]=tmp
    print(i,dy,dx,cor)

    z[i]=(z[i]/z[i].mean()*10000)
    

avgZ=z.mean(axis=0)
print('finished alignment')
#
#[BESTone,idBest ] = pickAG(z,1);  %%%%%%%%全幅选帧函数 ！！！！！！！！！！！！！！！！！！！！！1
#
#NEW=BESTone;
#
#%分块
bline=maxdxy*2+border
#
M=m//blockx #块尺寸
N=n//blocky

z=np.pad(z,((0,0),(bline,bline),(bline,bline)),mode='edge') #%为处理边界部分，先将图像扩展一下
avgz=np.pad(avgZ,bline,'edge')

frame=np.zeros((m+bline,n+bline)) #初始化输出数组
bw=frame.copy() #权重数组
#
wm=M+bline-2*maxdxy
wn=N+bline-2*maxdxy
blw=np.ones((wm,wn)) #权重块
#
z=np.vstack((avgz[np.newaxis,:,:],z))
for i in range(blockx):
    print(i)
    for j in range(blocky):

        z1=z[:,i*M:(i+1)*M+bline,j*N:(j+1)*N+bline]
        A0=AG(z1)

#        [ A0,id ] =  pickAG(z1,sc); %%%%%%%%%子块选帧函数 ！！！！！！！！！！！！！！！！！！！11
        # imj=avgz[i*M:(i+1)*M+bline,j*N:(j+1)*N+bline]
        
        # dy,dx,cor=sim.cc(imj,A0)  #位移
        # print(i,j,dx,dy)
        # A0=imshift(A0,[dx,dy])
#  
        X0=i*M+maxdxy
        X1=(i+1)*M+bline-maxdxy;
        Y0=j*N+maxdxy
        Y1=(j+1)*N+bline-maxdxy;
#     
        bw[X0:X1,Y0:Y1]=bw[X0:X1,Y0:Y1]+blw #边框图像
#       
        frame[X0:X1,Y0:Y1]=frame[X0:X1,Y0:Y1]+A0[maxdxy:-maxdxy,maxdxy:-maxdxy]#; %子块拼接

New=frame[maxdxy:-bline-maxdxy,maxdxy:-bline-maxdxy]/bw[maxdxy:-bline-maxdxy,maxdxy:-bline-maxdxy]# %平均重叠边界

sim.fitswrite('NEW_gpu.fits',New.astype('float32'),header=None)

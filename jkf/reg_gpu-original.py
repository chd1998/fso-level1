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
#%New_DEConv: 退卷积的结果



#%%%%%%%%%%%%%%%%%%%参数表
import os
from matplotlib import pyplot as plt
import jkf.sim2 as sim
import numpy as np
import glob
from skimage import restoration
import scipy.ndimage as sn
#import scipy.fftpack as fft
import cupy as cp
sc=5 #最后需要选取的帧数

W=100 #长宽的分块大小  
border=5 #重叠边界宽度
maxdxy=10 #估计的最大位移量


def AG(Z): #选帧并对齐到第一帧(平均帧)
        z=Z.copy()
        T0=(z.shape[0]-1)//2 #选帧帧数
        R=np.zeros(z[0].shape)
        C=np.zeros(z[0].shape)
        tmp=np.zeros(z.shape[0])
        
        for i in range(1,z.shape[0]-1): #对2帧以后的计算AG
            R[:-1,:]=np.diff(z[i],axis=0)
            C[:,:-1]=np.diff(z[i],axis=1)
            tmp[i-1]=(R**2+C**2).mean() #计算平均梯度
            
        zid=np.argsort(tmp) #平均梯度排序
        sz=z[zid[-T0:]] #选帧最好的T0帧
        z=np.vstack((z[0][np.newaxis,:],sz)) #拼接到平均帧
        
        #########对齐到第一帧
        z0=sim.zscore2(z[0])
        s_gpu = cp.asarray(z0)
        s_gpu = cp.fft.fft2(s_gpu)    

        for i in range(1,z.shape[0]):
            dy,dx,cor=sim.cc_gpu(s_gpu,z[i],1)  #位移
#            print(dy,dx,cor)
            if np.abs(dy)<maxdxy and np.abs(dx)<maxdxy: #位移太大就算了
                z[i]=sim.imshift(z[i],[dy,dx])
                
        return np.mean(z[1:],axis=0)    #返回平均


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#% 


dirnm='E:\\data\\短曝光-光球\\'
# dirnm='H:\\HA\\041226\\CENT\\041226\\'
# dirnm='H:\\TIO\\064612\\064612\\'
#dirnm='E:\\data\\Onset\\4250a\\'
# dirnm='E:\\data\\Onset\\Ha+00_20170328T053626P\\'
filenm='*.fits'

filelist=sorted(glob.glob(dirnm+filenm))
tot=len(filelist)

im0=sim.fitsread(filelist[0])[0]
m0,n0=im0.shape #原始图像尺寸
im0=im0/im0.mean()*10000 #归10000化


blockx=m0//W #可分割的块数
blocky=n0//W
m=blockx*W #实际处理的尺寸
n=blocky*W
dn=round((n0-n)/2) #扣除的边框
dm=round((m0-m)/2)

t=tot #处理多少帧

z=[]
#建立三维数据组
for i in range(t):
#    print(i)
    file =filelist[i]
    tmp=sim.fitsread(file)[0]
    z.append(tmp[dm:m+dm,dn:n+dn])
z=np.array(z)
im0=im0[dm:m+dm,dn:n+dn]
print('finished read data')
#z 为三维数据矩阵，一帧代表一个时刻的图像 ！！！！！！！！！！！！！！ 




#%%%%%%%%%%%%%整幅对齐
l,m,n=z.shape
width=m//4 #对齐标准区域的半宽度

firstim=np.double(z[0,m//2-width:m//2+width,n//2-width:n//2+width])
firstim = sim.zscore2(firstim)

s_gpu = cp.asarray(firstim)
s_gpu = cp.fft.fft2(s_gpu)

z[0]=(z[0]/z[0].mean()*10000)

for i in range(1,l):
    
    dy,dx,cor=sim.cc_gpu(s_gpu,z[i,m//2-width:m//2+width,n//2-width:n//2+width],1) #相对于第一帧的偏移量   
    tmp=sim.imshift(z[i],[dy,dx])#选取中心区，并进行整数象元对齐
    z[i]=tmp
    print(i,np.round([dy,dx,cor],2))
    z[i]=(z[i]/z[i].mean()*10000)
    

avgZ=z.mean(axis=0)
print('finished alignment')

bline=maxdxy*2+border #边框
#
M=m//blockx #块尺寸
N=n//blocky

z=np.pad(z,((0,0),(bline,bline),(bline,bline)),mode='reflect') #%为处理边界部分，先将图像扩展一下
avgZ=np.pad(avgZ,bline,'reflect')

frame=np.zeros((m+bline,n+bline)) #初始化输出数组
bw=frame.copy() #权重数组
#
wm=M+border
wn=N+border
blw=np.ones((wm,wn)) #权重块
#
z=np.vstack((avgZ[np.newaxis,:,:],z)) #把平均帧拼接为第一帧
for i in range(blockx):
    print(i)
    for j in range(blocky):

        z1=z[:,i*M:(i+1)*M+bline,j*N:(j+1)*N+bline] #切块
        A0=AG(z1) #选帧并对齐到第一帧

        X0=i*M+maxdxy
        X1=(i+1)*M+maxdxy+border
        Y0=j*N+maxdxy
        Y1=(j+1)*N+maxdxy+border
     
        bw[X0:X1,Y0:Y1]=bw[X0:X1,Y0:Y1]+blw #边框图像
       
        frame[X0:X1,Y0:Y1]=frame[X0:X1,Y0:Y1]+A0[maxdxy:-maxdxy,maxdxy:-maxdxy]#; %子块拼接

#切掉边
New=sim.removenan(frame[maxdxy+bline+border:-bline,maxdxy+bline+border:-bline]/bw[maxdxy+bline+border:-bline,maxdxy+bline+border:-bline])# %平均重叠边界

#对应的斑点像
im0=im0[:New.shape[0],:New.shape[1]]

#退卷积的PSF
psf=sim.makeGaussian(121, sigma =7, center=None)
psf/=psf.sum()

#退卷积
New_DEConv = restoration.unsupervised_wiener(New, psf, clip=False)[0]
#New_DEConv=restoration.richardson_lucy(New, psf, iterations=50, clip=False)

#增强
New_eh=(New_DEConv-sn.gaussian_filter(New_DEConv, 15))+New_DEConv

# psf=sim.makeGaussian(121, sigma = 3, center=None)
# psf/=psf.sum()
# Newss = restoration.unsupervised_wiener(New, psf, clip=False)
# import scipy.ndimage as sn
# Newgl=(Newss[0]-sn.gaussian_filter(Newss[0], 3))*3+Newss[0]
#Newgl=(New-sn.gaussian_filter(New, 3))*3+New

img=(np.stack((im0,New,New_DEConv,New_eh)))
sim.fitswrite('NEW_gpu.fits',img[1:].astype('float32'),header=None)

#########显示
x=[3,900]
y=[3,900]
sim.showim(sim.combin_img(img[:,x[0]:x[1],y[0]:y[1]],2))

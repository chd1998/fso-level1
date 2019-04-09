Instruction
Reversion 01
名称：
Solar Image Registration(sir) for FSO
用途：
用于NVST图像的对齐
操作系统：
Windows: 7以上
Linux
发布版本：
	Sir-fso-01: 普通Python版本，需要安装Python，并安装numpy, scipy, astropy, matplotlib等包
	Sir-fso-cuda-01:gpu加速Python版本，需要安装python,并安装numpy,scipy,astropy,cudatoolkit,cupy等包
版本历史：
2018/12/15: 季凯帆，原型版本
2019/02/05: 陈东，cuda(cupy)加速版本01，仅支持nvidia系列gpu
2019/02/08: 陈东，普通Python改进版本01
使用环境安装：
	Python：
	推荐安装anaconda 最新版本，下载地址：https://www.anaconda.com/distribution/#download-section
	安装numpy, scipy, astropy:
	打开anaconda command prompt, 执行：
	  Conda install numpy scipy astropy matplotlib
    pip install opencv
	安装 python cuda相关包(需要Nvidia 系列GPU支持)：
	Windows系统需要安装microsoft vs 2017；linux需要安装g++,linux源码，等---（细节请联系陈东解决）
	安装nvidia cudatoolkit, 下载地址：https://developer.nvidia.com/cuda-downloads，选择相应系统版本后下载
	Conda install cudatoolkit
	Conda install cupy
使用说明：
	Windows:
	打开anaconda command prompt
	进入程序目录，执行：
	python sir-fso-01.py -p <inputpath> -i <inputfile> -d<debug> --sx <num1> --sy <num2> --ex <num3> --ey <num4> -v <videofile> -o<output>

	Linux：
	打开一个Terminal
	进入程序目录，执行：
	python sir-fso-cuda-01.py -p <inputpath> -i <inputfile> -d<debug> --sx <num1> --sy <num2> --ex <num3> --ey <num4> -v <videofile> -o<output>
例：
Python sir-fso-cuda-01.py -p d:\data\  -i *.fits -d True --sx 250 --sy 250 --ex 750 --ey 750 -v test.avi -o True

参数说明：
-p  	数据文件目录, 默认当前目录
-I  		数据文件类型，默认 *.fits
-d 		是否输出debug信息，默认False
--sx 	图像特征选择起始点x坐标，默认250
--sy 	图像特征选择起始点y坐标，默认250
--ex 	图像特征选择结束点x坐标，默认750
--ey 	图像特征选择结束点y坐标，默认750
-v 		输出视频文件，默认文件名 test.avi
-o		是否输出对齐后文件，默认False；如果选True,将在输入数据目录想建立一个sir目录，并生成以sir开头的对齐后文件

对比：
	对齐285幅fso复原图像，1024*1024，16位，生成对齐后图像。测试机配置：AMD Ryzen 1700X, 16G DDR4, NVIDIA Quadro P2000：
	普通python版本： 		1532.00 secs
	Cuda(cupy)加速版本：		464.15  secs

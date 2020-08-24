import fft
import matplotlib.pyplot as plt
import numpy as np

num=1024
x=np.arange(0,num)
y=np.zeros(num)
R = fft.new_floatArray(num)
I = fft.new_floatArray(num)

for i in range(num):
    fft.floatArray_setitem(R, i, np.sin(i))
    fft.floatArray_setitem(I, i, np.cos(i))

#for i in range(num//4):
#    fft.floatArray_setitem(R, i, 1)

fft.ComplexFFT(R, I, num, 0)
fft.ComplexFFT(R, I, num, 1)

for i in range(num):
#    print ("[%10f %10f]" %(fft.floatArray_getitem(R, i), fft.floatArray_getitem(I, i)))
    y[i]=fft.floatArray_getitem(R, i)

plt.plot(x,y)
plt.show()

fft.delete_floatArray(R)
fft.delete_floatArray(I)


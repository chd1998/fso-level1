'''
usage: python -m timeit 'test.py'
'''
from __future__ import print_function, division, absolute_import
from numba import cuda, void, float64, complex128, boolean
import cupy as cp
import numpy as np
import timeit
import fft

@cuda.jit(void(float64[:],boolean, complex128[:]))
def fftbench(y, inverse, FT):
    Y  = cuda.local.array(256, dtype=complex128)
    for i in range(len(y)):
        Y[i]=complex128(y[i])
    fft.gtransform_radix2(Y, False, FT)

if __name__ == '__main__':
    print("test started!")
    str='\nbest [%2d/%2d] iterations, min:[%9.3f], max:[%9.3f], mean:[%9.3f], std:[%9.3f] usec'
    a=np.random.rand(1024)
    y1 =cp.zeros(len(a), cp.complex128)
    FT1=cp.zeros(len(a), cp.complex128)

    for i in range(len(a)):
        y1[i]=a[i]  #convert to complex to feed the FFT

    #r=1000
    fftbench[1,64](y1, False, FT1)
    #series=sorted(timeit.repeat("fftbench[1,64](y1, False, FT1)",      number=1, repeat=r, globals=globals()))
    #series=series[0:r-5]
    #print (str % (len(series), r, 1e6*np.min(series), 1e6*np.max(series), 1e6*np.mean(series), 1e6*np.std(series)))
    print ("test ended!")

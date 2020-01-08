from numba import cuda,jit
import numpy as np

@cuda.jit
def cudaposition():
    # Thread id in a 1D block
    tx = cuda.threadIdx.x
    # Block id in a 1D grid
    ty = cuda.blockIdx.x
    # Block width, i.e. number of threads per block
    bw = cuda.blockDim.x
    # Compute flattened index inside the array
    pos = tx + ty * bw
    # Check array boundaries
    return  tx,ty,bw
    

#a=np.zeros(1024,dtype='int16')
tx,ty,bw=cudaposition()
print ('cuda thread:%d  blockid:%d  block width:%d' %(tx,ty,bw))

from numba import cuda, boolean, void, int32, float32, float64, complex128
import math, sys, cmath

def _transform_radix2(vector, inverse, out):
    n = len(vector)
    levels = int32(math.log(float32(n))/math.log(float32(2)))
    assert 2**levels==n # error: Length is not a power of 2

    exptable = cuda.shared.array(1024, dtype=complex128)
    working = cuda.shared.array(256, dtype=complex128)

    assert (n // 2) <= len(exptable)  # error: FFT length > MAXFFTSIZE

    coef = complex128((2j if inverse else -2j) * math.pi / n)
    if idx < n // 2:
        exptable[idx] = cmath.exp(idx * coef)

    x = idx
    y = 0
    for j in range(levels):
        y = (y << 1) | (x & 1)
        x >>= 1
    working[idx] = vector[y]
    cuda.syncthreads()

    size = 2
    while size <= n:
        halfsize = size // 2
        tablestep = n // size

        if idx < 128:
            j = (idx%halfsize) + size*(idx//halfsize)
            k = tablestep*(idx%halfsize)
            temp = working[j + halfsize] * exptable[k]
            working[j + halfsize] = working[j] - temp
            working[j] += temp
        size *= 2
        cuda.syncthreads()

    scale=float64(n if inverse else 1)
    out[idx]=working[idx]/scale   # the inverse requires a scaling

# now create the Numba.cuda version to be called by a GPU
gtransform_radix2 = cuda.jit(device=True)(_transform_radix2)
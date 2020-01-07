import pyculib.fft
import numba.cuda
import numpy as np

@numba.cuda.jit
def apply_mask(frame, mask):
    i, j = numba.cuda.grid(2)
    frame[i, j] *= mask[i, j]

# … skipping some array setup here: frame is a 720x1280 numpy array

out = np.empty_like(mask, dtype=np.complex64)
gpu_temp = numba.cuda.to_device(out)  # make GPU array
gpu_mask = numba.cuda.to_device(mask)  # make GPU array

pyculib.fft.fft(frame.astype(np.complex64), gpu_temp)  # implied host->device
apply_mask[blocks, tpb](gpu_temp, gpu_mask)  # all on device
pyculib.fft.ifft(gpu_temp, out)  # implied device->host
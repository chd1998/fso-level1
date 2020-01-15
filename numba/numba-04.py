import numpy as np
import numba as nb
import datetime

sz = 100000
iterations = 1000
#
@nb.jit(nopython=True, parallel=True,nogil=True)       #428753ms
#@nb.jit(nopython=True, parallel=False)                 #929284ms
def Rule30_code():
    v = np.zeros(sz, np.int8)
    v[sz//2] = 1
    test = np.zeros(sz, np.int8)
    for it in range(iterations):
        test[1:sz-1] = (v[:sz-2] << 2) + (v[1:sz-1] << 1) + v[2:]
        for i in range(1, sz-1):
            v[i] = 1 if (0 < test[i] < 5) else 0
    return v

start = datetime.datetime.now()
for i in range(0,10000):
    v_fast = Rule30_code()
print("Total time used: %d ms" %(int((datetime.datetime.now()-start).total_seconds() * 1000)))
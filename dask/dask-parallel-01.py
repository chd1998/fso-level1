from time import time
from dask.distributed import Client, progress
import dask.array as da

def square(x):
    return x ** 2


if __name__ == '__main__':
    MAX = 1000
    st = time()
    client = Client('127.0.0.1:58122')   # ip of your dask-scheduler
    A = client.map(square, range(MAX))
    total = client.submit(sum, A)
    print(total.result())
    et = time()
    print(et - st)

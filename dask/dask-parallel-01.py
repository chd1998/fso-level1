<<<<<<< HEAD
from dask.distributed import Client
from time import time

=======
from time import time
from dask.distributed import Client, progress
import dask.array as da
>>>>>>> d3e2cd1cb300c934676b1d0954c5c4cc62a27f05

def square(x):
    return x ** 2


if __name__ == '__main__':
    MAX = 1000
    st = time()
<<<<<<< HEAD
    client = Client('127.0.0.1:50859')   # change ip and port for your case
=======
    client = Client('127.0.0.1:58122')   # ip of your dask-scheduler
>>>>>>> d3e2cd1cb300c934676b1d0954c5c4cc62a27f05
    A = client.map(square, range(MAX))
    total = client.submit(sum, A)
    print(total.result())
    et = time()
<<<<<<< HEAD
    print(et - st)
=======
    print(et - st)
>>>>>>> d3e2cd1cb300c934676b1d0954c5c4cc62a27f05

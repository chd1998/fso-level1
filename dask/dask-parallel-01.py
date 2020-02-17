from dask.distributed import Client
from time import time


def square(x):
    return x ** 2


if __name__ == '__main__':
    MAX = 1000
    st = time()
    client = Client('127.0.0.1:50859')   # change ip and port for your case
    A = client.map(square, range(MAX))
    total = client.submit(sum, A)
    print(total.result())
    et = time()
    print(et - st)
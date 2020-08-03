import sys
import asyncio
import itertools


@asyncio.coroutine
def spin(msg):
    write, flush = sys.stdout.write, sys.stdout.flush
    for char in itertools.cycle('|/-\\'):
        status = char + ' ' + msg
        write(status)
        flush()
        write('\x08' * len(status))
        try:
            yield  from asyncio.sleep(.1)  # 协程 asyncio.sleep 通过 yield from 调用
        except asyncio.CancelledError:
            break
    write(' ' * len(status) + '\x08' * len(status))


@asyncio.coroutine
def slow_func():
    yield from asyncio.sleep(3) # 把控制权交给主循环
    return 42


@asyncio.coroutine
def supervisor():
    spinner = asyncio.create_task(spin('thinking!')) # 协程 spin 通过 asyncio.creat_task 调用
    print('spinner object:', spinner)  # Task 对象，类似 Thread 对象
    result = yield from slow_func()  # 协程 slow_func 通过 yield from 调用
    spinner.cancel()
    return result


def main():
    loop = asyncio.get_event_loop()
    result = loop.run_until_complete(supervisor())  # 驱动协程
    loop.close()
    print('Answer:', result)


if __name__ == '__main__':
    main()

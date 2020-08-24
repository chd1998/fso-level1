'''
#!/usr/bin/env python
'''
from distutils.core import setup, Extension

example_module = Extension('_fft',
    sources=['fft.cpp', 'fft_wrap.cxx',], )

setup (name = 'fft',
       version = '0.1',
       author      = "wujian",
       description = """FFT implement by C""",
       ext_modules = [example_module],
       py_modules = ["fft"],
)

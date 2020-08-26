"""
setup.py file for SWIG C++/Python example
"""
import os
from os.path import join as pjoin
import numpy as np
from setuptools import setup
# from distutils.extension import Extension
from Cython.Distutils import build_ext
from torch.utils.cpp_extension import CppExtension
from torch.utils.cpp_extension import BuildExtension, CUDAExtension

nvcc_bin = 'nvcc.exe'
lib_dir = 'lib/x64'
def find_in_path(name, path):
    "Find a file in a search path"
    for dir in path.split(os.pathsep):
        binpath = pjoin(dir, name)
        if os.path.exists(binpath):
            return os.path.abspath(binpath)
    return None

def locate_cuda():
    """Locate the CUDA environment on the system

    Returns a dict with keys 'home', 'nvcc', 'include', and 'lib64'
    and values giving the absolute path to each directory.

    Starts by looking for the CUDAHOME env variable. If not found, everything
    is based on finding 'nvcc' in the PATH.
    """

    # first check if the CUDAHOME env variable is in use
    if 'CUDA_PATH' in os.environ:
        home = os.environ['CUDA_PATH']
        print("home = %s\n" % home)
        nvcc = pjoin(home, 'bin', nvcc_bin)
    else:
        # otherwise, search the PATH for NVCC
        default_path = pjoin(os.sep, 'usr', 'local', 'cuda', 'bin')
        nvcc = find_in_path(nvcc_bin, os.environ['PATH'] + os.pathsep + default_path)
        if nvcc is None:
            raise EnvironmentError('The nvcc binary could not be '
                'located in your $PATH. Either add it to your path, or set $CUDA_PATH')
        home = os.path.dirname(os.path.dirname(nvcc))
        print("home = %s, nvcc = %s\n" % (home, nvcc))


    cudaconfig = {'home':home, 'nvcc':nvcc,
                  'include': pjoin(home, 'include'),
                  'lib64': pjoin(home, lib_dir)}
    for k, v in cudaconfig.items():
        if not os.path.exists(v):
            raise EnvironmentError('The CUDA %s path could not be located in %s' % (k, v))

    return cudaconfig



CUDA = locate_cuda()
#print(CUDA)

example_module =CUDAExtension('_helloswig',
                sources=[    
                'hello-swig_wrap.cxx',
                'hello-swig.cu',
                ], 
              library_dirs=[CUDA['lib64']],
              #libraries=['cudart','cufft',],
              language='c++',
              # runtime_library_dirs=[CUDA['lib64']],
              # this syntax is specific to this build system
              # we're only going to use certain compiler args with nvcc and not with
              # gcc the implementation of this trick is in customize_compiler() below
              extra_compile_args={'cxx':[],#'gcc': ["-Wno-unused-function"],
                                  'nvcc': ['-arch=sm_61',
                                           '--ptxas-options=-v',
                                           '-c',
                                           '--compiler-options',
                                           ]},
              include_dirs=[np.get_include(), CUDA['include']]
              )

setup (
    name = 'helloswigcuda',
    ext_modules = [example_module],
    cmdclass={

    'build_ext':BuildExtension
    }

)
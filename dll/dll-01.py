import ctypes
import os

CUR_PATH=os.path.dirname(__file__)
dllPath=os.path.join(CUR_PATH,"atcore.dll")
print (dllPath)
#mydll=ctypes.cdll.LoadLibrary(dllPath)
#print mydll
pDll=ctypes.WinDLL(dllPath)
print (pDll)


camHdlr=ctypes.c_long
res=pDll.AT_InitialiseLibrary();
print(res)
handler=camHdlr(0)
pDll.AT_Open.argtypes=[ctypes.c_int,ctypes.POINTER(camHdlr)]
pDll.AT_Open.restype=ctypes.c_int
ret=pDll.AT_Open(0,ctypes.byref(handler))
print(ret)
import pynvml
pynvml.nvmlInit()
# GPU id 
handle = pynvml.nvmlDeviceGetHandleByIndex(0)
meminfo = pynvml.nvmlDeviceGetMemoryInfo(handle)
print("Total Mem(MB): %d" meminfo.total/(1024*1024)) #total Mem
print(meminfo.used)  #mem used
print(meminfo.free)  #mem free
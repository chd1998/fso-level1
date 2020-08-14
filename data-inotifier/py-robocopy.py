#-*- coding: utf-8 -*-
'''
@author: Chen Dong
@institution: Yunnan Astronomical Observatory, CAS

USAGE:
        python sync-watch-win-Revxx.py para1 para2 para3
            para1: src dir 
            para2: dest dir
            para3: thread no.
        example:
        python sync-watch-win-Rev08-01.py e:\test d:\test 32
IMPORTANT：
    1. copy contents in sorce directory to dest directory 
    2. works on windows platform only
        
#Known Issues:
    1.  don't support file/directory name with spaces  

2019/04/01 Release 01
    Prototype version
2019/04/13 Release 02:
    #Function:
        First working with GBK encoding
2019/04/14 Release 03:
    #Function:
        add support to input source/destination from command prompt
2019/04/14 Release 04:
    #OPTIMIZE:
        output and color scheme
20200622 Release 05:
    #OPTIMIZE:
        using fire arguments instead of opt
20200623 Release 06:
    #OPTIMIZE:
        using fire arguments instead of opt and working now
20200623 Release 07:
    #OPTIMIZE:
        test 2 dirs exist or not
20200727 Release 08:
    #REVISE:
        change dest to local/network dir under windows
        using robocopy inside windows system
20200728 Release 08-01:
    #REVISE:
        add threadnumber for robocopy
        add size compare between src and dest
        add speed info
20200810 Release py-robocopy-Rev01:
    #REVISE:
        change file name to py-robocopy-Rev01.py 
        revise exception handling
20200814 Release py-robocopy-Rev01:
    #REVISE:
        change file name to py-robocopy.py 
'''
from os import truncate
import subprocess
import os
import sys
import time
import random
import locale
import fire
from colorama import Fore,Back,Style
from colorama import init

def getFileSize(filePath, size=0):
    for root, dirs, files in os.walk(filePath):
        for f in files:
            size += os.path.getsize(os.path.join(root, f))
            #print(f)
    return size

def pysync(syncSrc,syncDes,threadNo):
    init(autoreset=True)
    if threadNo < 1 or threadNo > 128:
        threadNo=8
    if not os.path.exists(syncSrc):
        print ("Src Folder %s  does not exist, pls check..." %(syncSrc))
        sys.exit(0)
        
    if not os.path.exists(syncDes):
        print ("Making Dest Folder %s ..." %(syncDes))
        os.makedirs(syncDes)

    print(Fore.CYAN+"Syncing Data for NVST")
    print(Fore.CYAN+"Rev.02 2020-08-14")
    print(Fore.YELLOW+"%s --- Syncing Started with %s Thread(s)..." %(time.ctime(),str(threadNo)))
    
    #while retcode != 0: 
    cmd='cd '+syncSrc+' && '+'start /b '+'robocopy  '+syncSrc+' '+syncDes+' /E /COPY:DT /MT:'+str(threadNo)
    print(Fore.LIGHTMAGENTA_EX+'%s --- Syncing Data from %s to %s, pls wait...' %(time.ctime(),syncSrc,syncDes))
    start_time=time.time()
    try:
        syncAction=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
    #    syncAction.wait()
    except KeyboardInterrupt:
        print("Ctrl-C Breaked!")
        sys.exit(1)
    except :
        print("Error(s) found, pls check...")
        sys.exit(1)
    #syncStat=syncAction.communicate()[0].decode('gbk')
    #syncErr=syncAction.communicate()[1].decode('gbk')
    while syncAction.poll() is None:
        print(Fore.LIGHTMAGENTA_EX+'%s --- Syncing Data from %s to %s, pls wait...' %(time.ctime(),syncSrc,syncDes))
        time.sleep(1)
    retcode=syncAction.returncode
    srcSize=getFileSize(syncSrc)
    desSize=getFileSize(syncDes)
    used_time=time.time()-start_time
    if retcode == 0:
        print (Fore.LIGHTCYAN_EX+Back.BLACK+"%s ---  Sync Suceeded! " % (time.ctime()))
        print (Fore.LIGHTCYAN_EX+Back.BLACK+"%s ---  Src Size : %s KB" % (time.ctime(),str(srcSize/1000)))
        print (Fore.LIGHTCYAN_EX+Back.BLACK+"%s ---  Des Size : %s KB" % (time.ctime(),str(desSize/1000)))
        print (Fore.LIGHTCYAN_EX+Back.BLACK+"%s ---    @Speed : %.4f KB/sec." % (time.ctime(),(desSize/1000)/used_time))
        print (Fore.LIGHTCYAN_EX+Back.BLACK+"                            Time Used : %.4f Secs... " %(used_time))
        #print (rsyncStat+"\n")
    else:
        print (Fore.LIGHTYELLOW_EX+Back.RED+'Failed: Sync failed!')

if __name__ == '__main__':
    fire.Fire(pysync)
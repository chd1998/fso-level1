#-*- coding: utf-8 -*-
'''
@author: Chen Dong
@institution: Yunnan Astronomical Observatory, CAS

USAGE:
        python sync-watch-win-Revxx.py para1 para2 
            para1: src dir 
            para2: dest dir
        example:
        python sync-watch-win-Rev08-01.py e:\test d:\test
IMPORTANT：
    1. copy contents in sorce directory to dest directory 
    2. works on windows platform only

2019/04/01 Release 01
    Prototype version
2019/04/13 Release 02:
    #Function:
        First working with GBK encoding
    #Known Issues:
        don't support file/directory name with spaces
2019/04/14 Release 03:
    #Function:
        add support to input source/destination from command prompt
    Known Issues:
        don't support file/directory name with spaces
2019/04/14 Release 04:
    #OPTIMIZE:
        output and color scheme
    #Known Issues:
        don't support file/directory name with spaces
20200622 Release 05:
    #OPTIMIZE:
        using fire arguments instead of opt
    #Known Issues:
        don't support file/directory name with spaces
20200623 Release 06:
    #OPTIMIZE:
        using fire arguments instead of opt and working now
    #Known Issues:
        don't support file/directory name with spaces
20200623 Release 07:
    #OPTIMIZE:
        test 2 dirs exist or not
    #Known Issues:
        don't support file/directory name with spaces
20200727 Release 08:
    #REVISE:
        change dest to local/network dir under windows
        using robocopy inside windows system
    #Known Issues:
        don't support file/directory name with spaces
20200728 Release 08-01:
    #REVISE:
        add threadnumber for robocopy
        add size compare between src and dest
        add speed info
    #Known Issues:
        don't support file/directory name with spaces
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
        print ("Folder %s  not ready, pls wait..." %(syncSrc))
        sys.exit(0)
        
    if not os.path.exists(syncDes):
        os.makedirs(syncDes)

    print(Fore.CYAN+"Syncing Data for NVST")
    print(Fore.CYAN+"Rev.08-01 2020-07-27")
    print(Fore.YELLOW+"%s --- Syncing Started with %s Thread(s)..." %(time.ctime(),str(threadNo)))
    
    #while retcode != 0: 
    cmd='cd '+syncSrc+' && '+'start /b '+'robocopy  '+syncSrc+' '+syncDes+' /E /COPY:DT /MT:'+str(threadNo)
    print(Fore.RED+'%s --- Syncing Data from %s to %s' %(time.ctime(),syncSrc,syncDes))
    start_time=time.time()
    try:
        syncAction=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
        syncAction.wait()
    except KeyboardInterrupt:
        print("Ctrl-C Breaked!")
        sys.exit(1)
    syncStat=syncAction.communicate()[0].decode('gbk')
    syncErr=syncAction.communicate()[1].decode('gbk')
    retcode=syncAction.returncode
    end_time=time.time()
    srcSize=getFileSize(syncSrc)
    desSize=getFileSize(syncDes)
    used_time=end_time-start_time
    if retcode == 0:
        print (Fore.LIGHTCYAN_EX+Back.BLACK+"%s --- Sync Suceeded! " % (time.ctime()))
        print (Fore.LIGHTCYAN_EX+Back.BLACK+"%s --- Src Size : %s KB" % (time.ctime(),str(srcSize/1000)))
        print (Fore.LIGHTCYAN_EX+Back.BLACK+"%s --- Des Size : %s KB" % (time.ctime(),str(desSize/1000)))
        print (Fore.LIGHTCYAN_EX+Back.BLACK+"%s ---   @Speed : %.4f KB/sec." % (time.ctime(),(desSize/1000)/used_time))
        print (Fore.LIGHTCYAN_EX+Back.BLACK+"Time Used: %.4f Secs... " %(used_time))
        #print (rsyncStat+"\n")
    else:
        print (Fore.LIGHTYELLOW_EX+Back.RED+'Failed: Sync failed!')

if __name__ == '__main__':
    fire.Fire(pysync)
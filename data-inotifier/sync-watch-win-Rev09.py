#-*- coding: utf-8 -*-
'''
@author: Chen Dong
@institution: Yunnan Astronomical Observatory, CAS

USAGE:
        python sync-watch-win-Revxx.py para1 para2 
            para1: src dir 
            para2: dest dir
           

        example:
        python sync-watch-win-Rev08.py e:\test d:\test
IMPORTANT：
    1. monitoring sorce directory and copy to dest directory 
    2. works on windows platform only
    3. inotifywait.exe must be in the same directory of this file

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
20200643 Release 07:
    #OPTIMIZE:
        test 2 dirs exist or not
    #Known Issues:
        don't support file/directory name with spaces
20200643 Release 08:
    #REVISE:
        change dest to local/network dir under windows
        using copy inside windows system
    #Known Issues:
        don't support file/directory name with spaces
'''
import subprocess
import os
import sys
import time
import random
import locale
import fire
from colorama import Fore,Back,Style
from colorama import init
import inotify.adapters

def pysync(syncSrc,syncDes):
    init(autoreset=True)
    if not os.path.exists(syncSrc):
        print ("Folder %s doesn't exist!  Pls Check..." %(syncSrc))
        sys.exit(0)
    if not os.path.exists(syncDes):
        os.makedirs(syncDes)
    print(Fore.YELLOW+"%s Waiting for changes..." %(time.ctime()),end='\r')
    #i = inotify.adapters.Inotify()
    #i.add_watch(syncSrc)
    i = inotify.adapters.InotifyTree(syncSrc)
    
    for event in i.event_gen(yield_nones=False):
      (_, type_names, path, filename) = event    
      print("PATH=[{}] FILENAME=[{}] EVENT_TYPES={}".format(path, filename, type_names))
    
    pass

if __name__ == '__main__':
    fire.Fire(pysync)
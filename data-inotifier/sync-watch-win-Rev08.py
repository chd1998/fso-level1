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

def pysync(syncSrc,syncDes):
    init(autoreset=True)
    if not os.path.exists(syncSrc):
        print ("Folder %s doesn't exist!  Pls Check..." %(syncSrc))
        sys.exit(0)
    if not os.path.exists(syncDes):
        os.makedirs(syncDes)
    listen='inotifywait -mrq --format "%%e %%w\%%f" "%s"' %(syncSrc)
    #listen='inotifywait -mrq --format "%%e %%w\%%f" "d:\\test\\data"'
    popen=subprocess.Popen(listen,stdout=subprocess.PIPE)
    print(Fore.CYAN+"Syncing Data for NVST")
    print(Fore.CYAN+"Rev.08  2020-07-27")
    print(Fore.YELLOW+"%s Waiting for changes..." %(time.ctime()))
    while True:
        line=popen.stdout.readline().strip()
        lineArr=(line.decode('gbk')).split(' ')
        oper=lineArr[0]
        file=lineArr[1]
        a_ok=False
        while not a_ok:
            try:
                tmp_file=open(r"file",'ab+')
                a_ok=True
                tmp_file.close()
            except IOError as e:
                print("I/O error({0}): {1}".format(e.errno, e.strerror))
            except:
                print(Fore.RED+Back.BLACK+"%s --- Waiting for %s" %(time.ctime(),file))
                sys.stdout.flush()
                time.sleep(1)
        touched=False
        print(' ')
        #if file.index(rsyncSrc_orig)==0:
        if file.find(syncSrc)==0:
            if (oper=='CREATE') or (oper=='MOVE'):
            #if (oper=='MOVE') or (oper=='CREATE') or (oper=='DELETE') or (oper=='MODIFY'):
                cmd='cd '+syncSrc+' && '+'start /b '+'robocopy  '+syncSrc+' '+syncDes+' /S /COPY:DT'
                touched=True
        if touched:
            print(Fore.RED+'%s --- Syncing: %s to %s' %(time.ctime(),file,syncDes))
            start_time=time.time()
            syncAction=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
            syncStat=syncAction.communicate()[0].decode('gbk')
            syncErr=syncAction.communicate()[1].decode('gbk')
            retcode=syncAction.returncode
            #print(syncStat)
            #print(syncErr)
            end_time=time.time()
            used_time=end_time-start_time
            if retcode == 0:
                print (Fore.LIGHTCYAN_EX+Back.BLACK+"%s --- Succeed: %s synced! " % (time.ctime(),file))
                print (Fore.LIGHTCYAN_EX+Back.BLACK+"Time Used: %.4f Secs... " %(used_time))
                #print (rsyncStat+"\n")
            else:
                print (Fore.LIGHTYELLOW_EX+Back.RED+'Failed: '+file+' sync failed!')
                #print (rsyncStat+"\n")

if __name__ == '__main__':
    fire.Fire(pysync)
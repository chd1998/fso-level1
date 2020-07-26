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

def pysync(syncSrc,syncDes):
    init(autoreset=True)
    if not os.path.exists(syncSrc):
        print ("Folder %s doesn't exist!  Pls Check..." %(syncSrc))
        sys.exit(0)
    if not os.path.exists(syncDes):
        os.makedirs(syncDes)
        #print ("Folder %s doesn't exist!  Pls Check..." %(syncDes))
        #sys.exit(0)
    #cygrsyncPrefix='/cygdrive'
    #cygtmp=rsyncSrc_orig.replace('\\','/')
    #cygtmp=cygtmp.replace(':','')
    #cygrsyncSrc=cygrsyncPrefix+'/'+cygtmp
    #rsyncSrc=rsyncSrc_orig
    #print(rsyncSrc_orig)
    #print(rsyncDes)
    #print(cygrsyncSrc)
    listen='inotifywait -mrq --format "%%e %%w\%%f" "%s"' %(syncSrc)
    #listen='inotifywait -mrq --format "%%e %%w\%%f" "d:\\test\\data"'
    popen=subprocess.Popen(listen,stdout=subprocess.PIPE)
    print(Fore.YELLOW+"%s Waiting for changes..." %(time.ctime()),end='\r')
    while True:
        line=popen.stdout.readline().strip()
        #print (line)
        lineArr=(line.decode('gbk')).split(' ')
        oper=lineArr[0]
        file=lineArr[1]
        #filename=file.split('\\')[-1]
        #print(file)
        a_ok=False
        while not a_ok:
            try:
                tmp_file=open(file,"ab+")
                a_ok=True
                tmp_file.close()
            except:
                print(Fore.RED+Back.WHITE+"%s --- Waiting for %s" %(time.ctime(),file))
                sys.stdout.flush()
                time.sleep(1)
        touched=False
        print(' ')
        #if file.index(rsyncSrc_orig)==0:
        if file.find(syncSrc)==0:
            if (oper=='MOVED_TO') or (oper=='CREATE'):
                #_current_file=file.replace(rsyncSrc_orig,cygrsyncSrc)
                #_current_file=_current_file.replace(':','')
                #current_file=_current_file.replace('\\','/')
                #filename=file.split('\\')[-1]
                #current_file=str(filename)
                #print(current_file)
                #current_file='/cygdrive/e/test/data'
                #cmd='cd '+rsyncSrc+' && '+'start /b '+rsync_exec+'\\rsync.exe -av -R -d --port=873  --progress '+current_file+' '+rsyncDes
                #cmd='cd '+rsyncSrc+' && '+'start /b '+rsync_exec+'\\rsync.exe -av -R -d --port=873  --progress '+cygrsyncSrc+' '+rsyncDes
                cmd='cd '+syncSrc+' && '+'start /b '+'copy /Y '+syncSrc+' '+syncDes
                #print(cmd)
                #cmd=cmd.encode(locale.getdefaultlocale()[1])
                touched=True
        if touched:
            print(Fore.RED+Back.WHITE+'%s --- Syncing: %s' %(time.ctime(),file))
            start_time=time.time()
            syncAction=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
            syncStat=syncAction.communicate()[0].decode()
            syncErr=syncAction.communicate()[1].decode()
            print(syncStat,syncErr)
            end_time=time.time()
            used_time=end_time-start_time
            if 'speedup' in syncStat:
                print (Fore.LIGHTCYAN_EX+Back.BLACK+"%s --- Succeed: %s rsynced! " % (time.ctime(),file))
                print (Fore.LIGHTCYAN_EX+Back.BLACK+"Time Used: %.4f Secs... " %(used_time))
                #print (rsyncStat+"\n")
            else:
                print (Fore.LIGHTYELLOW_EX+Back.RED+'Failed: '+file+' rsync failed!')
                #print (rsyncStat+"\n")

if __name__ == '__main__':
    fire.Fire(pysync)
#-*- coding: utf-8 -*-
'''
@author: Chen Dong
@institution: Yunnan Astronomical Observatory, CAS
IMPORTANT：
    1. monitoring sorce directory and rsync to remote directory 
    2. works on windows platform only
    3. install cygwin with rsync module and python before running

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

'''
import subprocess
import os
import sys
import time
import random
import locale
import fire
#import getopt
from colorama import Fore,Back,Style
from colorama import init

#cygrsyncPrefix='/cygdrive'
#rsync_exec='c:\\cygwin64\\bin'
#rsyncSrc=''
#rsyncDes=''

def pyrsync(rsyncSrc_orig,rsyncDes,rsync_exec):
    init(autoreset=True)
    #rsyncSrc='d:\\test\\data'
    #cygrsyncSrc='/cygdrive/d/test/data'
    #rsyncDes='armnas-rock64::test'
    
    #cygtmp=rsyncSrc_orig.replace('\\','/')
    #cygtmp=cygtmp.replace(':','')
    #cygrsyncSrc=cygrsyncPrefix+'/'+cygtmp
    #rsyncSrc=rsyncSrc_orig.replace('\\','\\\\')
    rsyncSrc=rsyncSrc_orig
    #print(rsyncSrc_orig)
    #print(rsyncDes)
    #print(cygrsyncSrc)
    listen='inotifywait -mrq --format "%%e %%w\%%f" "%s"' %(rsyncSrc)
    #listen='inotifywait -mrq --format "%%e %%w\%%f" "d:\\test\\data"'
    popen=subprocess.Popen(listen,stdout=subprocess.PIPE)
    print(Fore.YELLOW+"%s Waiting for changes...\n" %(time.ctime()),end='\r')
    while True:
        line=popen.stdout.readline().strip()
        #print (line)
        lineArr=(line.decode('gbk')).split(' ')
        oper=lineArr[0]
<<<<<<< HEAD
        srcfile=lineArr[1]
        #rsyncSrc_name=str(file.split('\\')[-1])
=======
        file=lineArr[1]
        filename=file.split('\\')[-1]
>>>>>>> 4c6ec66fec1109ebee53053386b99e2af6e803fa
        #print(file)
        a_ok=False
        while not a_ok:
            try:
                tmp_file=open(srcfile,"ab+")
                a_ok=True
                tmp_file.close()
            except:
                print(Fore.RED+Back.WHITE+"%s --- Waiting for %s\n" %(time.ctime(),file),end='\r')
                sys.stdout.flush()
                time.sleep(1)
        touched=False
        print(' ')
        #if file.index(rsyncSrc_orig)==0:
<<<<<<< HEAD
        if srcfile.find(rsyncSrc_orig)==0:
=======
        if file.find(rsyncSrc)==0:
>>>>>>> 4c6ec66fec1109ebee53053386b99e2af6e803fa
            if (oper=='MOVED_TO') or (oper=='CREATE'):
                #_current_file=file.replace(rsyncSrc_orig,cygrsyncSrc)
                #_current_file=_current_file.replace(':','')
                #current_file=_current_file.replace('\\','/')
<<<<<<< HEAD
                filename=srcfile.split('\\')[-1]
=======
                #filename=file.split('\\')[-1]
>>>>>>> 4c6ec66fec1109ebee53053386b99e2af6e803fa
                current_file=str(filename)
                #print(current_file)
                #current_file='/cygdrive/e/test/data'
                #cmd='cd '+rsyncSrc+' && '+'start /b '+rsync_exec+'\\rsync.exe -av -R -d --port=873  --progress '+current_file+' '+rsyncDes
                cmd='cd '+rsyncSrc+' && '+'start /b '+rsync_exec+'\\rsync.exe -av -R -d --port=873  --progress '+current_file+' '+rsyncDes
                #print(cmd)
                #cmd=cmd.encode(locale.getdefaultlocale()[1])
                touched=True
        if touched:
            print(Fore.RED+Back.WHITE+'%s --- Rsyncing: %s\n' %(time.ctime(),srcfile))
            start_time=time.time()
            #rsyncAction=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
            rsyncAction=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=True)
            #while rsyncAction.poll()!=0:
            #    if rsyncAction.poll():
            #        break
            #print(cmd)
            #returncode=rsyncAction.poll()
            #print(returncode)
            rsyncStat=rsyncAction.communicate()[0].decode()
            rsyncErr=rsyncAction.communicate()[1].decode()
            #print(rsyncStat,rsyncErr)
            end_time=time.time()
            used_time=end_time-start_time
            if 'speedup' in rsyncStat:
                print (Fore.LIGHTCYAN_EX+Back.BLACK+"%s --- Succeed: %s rsynced! " % (time.ctime(),srcfile))
                print (Fore.LIGHTCYAN_EX+Back.BLACK+"Time Used: %.4f Secs... \n" %(used_time))
                #print (rsyncStat+"\n")
            else:
                print (Fore.LIGHTYELLOW_EX+Back.RED+'Failed: '+file+' rsync failed!\n')
                #print (rsyncStat+"\n")

            #sys.stdout.write(rsyncStat)
            #rsyncAction=subprocess.check_output(cmd1)
            #rsyncAction=subprocess.check_output(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,shell=True)

if __name__ == '__main__':
    fire.Fire(pyrsync)
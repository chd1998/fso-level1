#-*- coding: utf-8 -*-
import subprocess
import os
import sys
import time
import random

rsyncSrc='d:\\test\\data'
cygrsyncSrc='/cygdrive/d/test/data'
rsyncDes='armnas-rock64::test'
listen='inotifywait -mrq --format "%%e %%w\%%f" "d:\\test\\data"'
popen=subprocess.Popen(listen,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell=False)
print("Waiting for changes...")
while True:
    line=popen.stdout.readline().strip()
    #print (line)
    lineArr=(line.decode()).split(' ')
    oper=lineArr[0]
    file=lineArr[1]

    a_ok=False
    while not a_ok:
        try:
            tmp_file=open(file,"ab+")
            a_ok=True
            tmp_file.close()
        except:
            print("Waiting for "+file)
            time.sleep(random.randint(1,9))
    #while(not os.access(file,os.R_OK)):
    #    time.sleep(randdom.randint(1,9))
    #    print("Waiting for "+file+" ...")

    touched=False

    if file.index(rsyncSrc)==0:
        if (oper=='MOVED_TO') or (oper=='CREATE'):
            _current_file=file.replace(rsyncSrc,cygrsyncSrc)
            current_file=_current_file.replace('\\','/')
            #print(current_file)
            #current_file='/cygdrive/e/test/data'
            cmd='cd '+rsyncSrc+' && '+'start /b d:\\rsync\\rsync.exe -av -R -d --port=873  --progress '+current_file+' '+rsyncDes
            touched=True
    if touched:
        print('Rsyncing '+file)
        start_time=time.clock()
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
        end_time=time.clock()
        used_time=end_time-start_time
        if 'speedup' in rsyncStat:
            print ("Succeed: %s rsynced! " % (file))
            print ("using time: %.4f Secs...\n" %(used_time))
            #print (rsyncStat+"\n")
        else:
            print ('Failed: '+file+' rsync failed!\n')
            #print (rsyncStat+"\n")

        #sys.stdout.write(rsyncStat)
        #rsyncAction=subprocess.check_output(cmd1)
        #rsyncAction=subprocess.check_output(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,shell=True)

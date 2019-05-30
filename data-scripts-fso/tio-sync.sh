#!/bin/bash
#author: chen dong @fso
#purposes: periodically syncing data from remoteip to local lustre storage via lftp
#usage:  run in crontab every 1 min.  from 08:00-23:00
#example: none
#changlog: 
#      	20190420	release 0.1
#      	20190421    	release 0.2	fix bugs,using pid as lock to prevent script from multiple starting
#	20190427	release 0.3     sync only today's data
#	20190519        release 0.4     using lftp instead of wget
#    	20190530	release 0.5  	adding more info

procName="wget"
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"

destpre0="/lustre/data"
#srcpre0="ftp://tio:ynao246135@192.168.111.120"
srcpre0="ftp://192.168.111.120"
datatype="TIO"
remoteport="21"
user="tio"
password="ynao246135"

filenumber=/home/chd/log/$(basename $0)-number.dat
filesize=/home/chd/log/$(basename $0)-size.dat
lockfile=/home/chd/log/$(basename $0).lock
if [ ! -f $filenumber ];then
  echo "0">$filenumber
fi
if [ ! -f $filesize ];then 
  echo "0">$filesize
fi

if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    echo "$today $ctime: $(basename $0) is running" 
    exit 1
  else
    echo $$>$lockfile
  fi
else
  echo $$>$lockfile
fi

echo " "
echo "===== Welcome to Data Archiving System @ FSO! ====="
echo "                  tio-sync.sh                      "
echo "          (Release 0.5 20190530 11:42)             "
echo "                                                   "
echo "                $today $ctime                      "
echo "==================================================="
echo " "
procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
if [ $procCmd -le 0 ];then
  destpre=${destpre0}${syssep}${cyear}${syssep}
  if [ ! -d "$destpre" ]; then
    mkdir $destpre
  else
    echo "$today $ctime: $destpre exists!"
  fi
  destdir=${destpre}${today}${syssep}
  targetdir=${destdir}${datatype}
  srcdir=${srcpre0}${syssep}${today}${syssep}
  srcdir1=${srcpre0}:${remoteport}${syssep}${today}${syssep}
  
  n1=$(cat $filenumber)
  s1=$(cat $filesize)

  if [ ! -d "$destdir" ]; then
    mkdir $destdir
  else
    echo "$today $ctime: $destdir exists!"
  fi
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: Syncing $datatype data @ FSO..."
  echo "             From: $srcdir1 "
  echo "             To  : $destdir "
  echo "Please Wait ... "
  cd $destpre
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  mytime1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  #lftp -e "mirror --ignore-time --no-perms --continue --no-umask --exclude /\$RECYCLE.BIN/$ --exclude /System Volume Information/$  --parallel=30  / .; quit" ftp://tio:ynao246135@192.168.111.120:21/
  lftp -u $user,$password -e "mirror --ignore-time --no-perms --continue --exclude /\$RECYCLE.BIN/$  --parallel=33  / .; quit" $srcdir1 
  #wget  --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=tio --ftp-password=ynao246135 --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob --preserve-permissions $srcdir
  ctime2=`date --date='0 days ago' +%H:%M:%S`
  mytime2=`echo $ctime2|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  if [ $? -ne 0 ];then
    echo "$today $ctime2: Syncing $datatype Data @ FSO Failed!"
    cd /home/chd/
    exit 1
  fi
  
  n2=`ls -lR $targetdir | grep "^-" | wc -l`
  #chmod 777 -R $targetdir
  s2=`du -sm $targetdir|awk '{print $1}'`
  #cursize=`du -sm $cdir|awk '{print $1}'`
  sn=`echo "$n1 $n2"|awk '{print($2-$1)}'`
  ss=`echo "$s1 $s2"|awk '{print($2-$1)}'`
  timediff=`echo "$mytime1 $mytime2"|awk '{print($2-$1)}'`
  if [ $timediff -eq 0]; then
  	speed=0
  else
  	speed=`echo "$ss $timediff"|awk '{print($1/$2)}'`
  fi
  echo $n2>$filenumber
  echo $s2>$filesize
  echo "$today $ctime2: Succeeded in Syncing $datatype data @ FSO!"
  echo "                            Synced : $sn file(s)"
  echo "                            Synced : $ss MB "
  echo "                         Time used : $timediff secs."
  echo "                             Speed : $speed MB/s"
  echo "                        Total file : $n2 file(s)"
  echo "                        Total size : $s2 MB"
  echo "                         Time from : $ctime1"
  echo "                                to : $ctime2"
  rm -rf $lockfile
  cd /home/chd/
  exit 0
else
  echo "$today $ctime: $procName  is running..."
  echo "              PID: $pid                    "
  exit 0
fi


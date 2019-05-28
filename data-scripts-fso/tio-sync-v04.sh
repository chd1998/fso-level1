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

lockfile=/home/chd/log/$(basename $0).lock

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
echo "          (Release 0.4 20190519 06:11)             "
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

  srcdir=${srcpre0}${syssep}${today}${syssep}
  srcdir1=${srcpre0}:${remoteport}${syssep}${today}${syssep}

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
  #lftp -e "mirror --ignore-time --no-perms --continue --exclude /\$RECYCLE.BIN/$ --exclude /System Volume Information/$  --parallel=30  / .; quit" ftp://tio:ynao246135@192.168.111.120:21/
  lftp -u $user,$password -e "set net:max-retries 5;set net:reconnect-interval-base 5;set net:reconnect-interval-multiplier 1 ;mirror --ignore-time --no-perms --continue --exclude /\$RECYCLE.BIN/$  --parallel=33  / .; quit" $srcdir1 
  #wget  --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=tio --ftp-password=ynao246135 --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob --preserve-permissions $srcdir
  ctime2=`date --date='0 days ago' +%H:%M:%S`
  if [ $? -ne 0 ];then
    echo "$today $ctime2: Syncing $datatype Data @ FSO Failed!"
    cd /home/chd/
    exit 1
  fi
  targetdir=${destdir}${datatype}
  filenumber=`ls -lR $targetdir | grep "^-" | wc -l`
  #chmod 777 -R $targetdir
  targetsize=`du -sm $targetdir|awk '{print $1}'`
  #cursize=`du -sm $cdir|awk '{print $1}'`
  echo "$today $ctime2: Succeeded in Syncing $datatype data @ FSO!"
  echo "                            Synced : $filenumber file(s)"
  echo "                            Synced : $targetsize MB "
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


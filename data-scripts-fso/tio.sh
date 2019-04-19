#!/bin/bash
#author: chen dong @fso
#purposes: periodically rsync data from remoteip to local lustre storage
#usage:  run in crontab every 30 mins.  from 07:00-20:00
#example: none
#changlog: 
#      	  20190415              first prototype release 0.1
#      	  20190416              first working release 0.2
#      	  20190417-20190418    	fix bugs,using pid as lock to prevent script from multiple starting, release 0.3-0.5
#      	  20190419	        release	0.6

procName="rsync"
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"
destpre0="/lustre/data"
srcpre0="192.168.111.120::"
datatype="tio"
rsyncPort="875"
lockfile=/home/chd/log/$(basename $0)_lockfile

if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    echo "$todday $ctime: $(basename $0) is running" && exit 1
  else
    echo $$>$lockfile
  fi  
else
  echo $$>$lockfile
fi
#echo "Script is running!"
#read
#echo "Script stopped!"
#rm -rf $lockfile
procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
if [ $procCmd -le 0 ];then
  #echo "$today"
  #echo "$ctime"
  destpre=${destpre0}${syssep}${cyear}${syssep}
  srcpre=${srcpre0}${datatype}
  destdir=${destpre}${today}${syssep}
  srcdir=${srcpre}${syssep}${today}${syssep}
  if [ ! -d "$destdir" ]; then
    mkdir $destdir
  else
    echo "$destdir already exist!"
  fi
  echo "$today $ctime: Rsyncing from $srcdir to $destdir "
  echo "Please Waiting ... "
  rsync  --port=$rsyncPort --timeout=60 -auvgop --exclude="\$RECYCLE.BIN" --protocol=29  $srcdir $destdir
  chmod 777 -R $destdir
  echo "$today $ctime: Succeeded in Rsyncing $datatype data@FSO!"
  rm -rf $lockfile
  exit 0
else
  echo "$today $ctime: $procName  is running..."
  echo "              PID: $pid                    "
  exit 0
fi


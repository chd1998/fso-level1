#!/bin/bash
#author: chen dong @fso
#purposes: after daily crontab task, recheck the rsync data
#usage: run once in crontab at 20:30 everyday
#example: none
#changlog:
#         20190416              first working release 0.1
#         20190417-20190418     fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
#         20190419              release 0.3

procName="rsync"
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"
destpre0="/lustre/data"
srcpre0="192.168.111.120::"
datatype="tio"
rsyncPort="875"
procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
if [ $procCmd -le 0 ];then
  #echo "$today"
  #echo "$ctime"
  destpre=${destpre0}${syssep}${cyear}${syssep}
  srcpre=${srcpre0}${datatype}
  destdir=${destpre}${today}${syssep}
  srcdir=${srcpre}${syssep}${today}${syssep}
  #echo "From: $srcdir"
  #echo "To:   $destdir"
  if [ ! -d "$destdir" ]; then
    echo "ERROR: $destdir is missing!"
    echo "Please check the $destdir...."
    exit 1
  else
    echo "$destdir already exist!"
  fi
  echo "$today $ctime: Checking Rsync Results from $srcdir to $destdir "
  echo "Please Waiting ... "
  rsync  --port=$rsyncPort --timeout=60 -auqgop --exclude="\$RECYCLE.BIN" --protocol=29  $srcdir $destdir
  chmod 777 -R $destdir
  echo "$today $ctime: Succeeded in Rsyncing $datatype data@FSO!"
  exit 0
else
  echo "$today $ctime: $procName is running..."
  exit 0
fi

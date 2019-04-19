#!/bin/bash
#purposes: to check the local data with remote ip
#usage: usage: ./tio-data-check.sh  tio/ha srcip year(in 4 digits) monthday(in 4 digits) destdir
#example: ./tio-data-check.sh  tio 192.168.111.70 2019 0420 /lustre/data
#changlog:
#         20190419              first release 0.1

procName="rsync"
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"
#destpre0="/lustre/data"
#srcIP="192.168.111.120"
#srcpre0=${srcIP}::
#datatype="tio"
rsyncPort="875"
#srcyear=""
#srcday=""
datatype=$1
srcIP=$2
srcyear=$3
srcday=$4
destdir=$5


if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] || [[ -z $5 ]] ;then
  echo "usage: ./tio-data-check.sh  tio/ha srcip year(in 4 digits) monthday(in 4 digits) destdir"
  exit 1
fi

srcpre0=${srcIP}::


procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
#procCmd=0
if [ $procCmd -le 0 ];then
  #echo "$today"
  #echo "$ctime"
  destpre=${destpre0}${syssep}${srcyear}${syssep}
  srcpre=${srcpre0}${datatype}
  destdir=${destdir}${syssep}${srcyear}${srcday}${syssep}
  srcdir=${srcpre}${syssep}${srcyear}${srcday}${syssep}
  echo "From: $srcdir"
  echo "To:   $destdir"
  if [ ! -d "$destdir" ]; then
    echo "ERROR: $destdir is missing!"
    echo "Please check the $destdir...."
    exit 1
  else
    echo "$destdir already exist!"
  fi
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: Checking Rsync Results of $datatype data@FSO"
  echo "From: $srcdir:
  echo "To  : $destdir @ $srcyear$srcday"
  echo "Please Waiting ... "
  rsync  --port=$rsyncPort --timeout=60 -auqgop --exclude="\$RECYCLE.BIN" --protocol=29  $srcdir $destdir
  chmod 777 -R $destdir
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime1: Succeeded in Rsyncing $datatype data@FSO!"
  echo "Time used: $ctime to $ctime1"
  exit 0
else
  echo "$today $ctime: $procName is running..."
  exit 0
fi

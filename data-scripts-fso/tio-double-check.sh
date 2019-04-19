#!/bin/bash
# purposes: compare data on remote observation pc and local lustre @fso
# usage: ./tio-double-check.sh year monthday
# example: ./tio-double-check.sh 2019 0420
#changlog:
#         20190418              first prototype release 0.1
#         20190418-20190419     fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
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
#srcyear=""
#srcday=""

srcyear=$1
srcday=$2

if [[ -z $1 ]] || [[ -z $2 ]];then
  echo "usage: ./tio-double-check.sh  year(in 4 digits) monthday(in 4 digits)"
  exit 1
fi

procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
#procCmd=0
if [ $procCmd -le 0 ];then
  #echo "$today"
  #echo "$ctime"
  destpre=${destpre0}${syssep}${srcyear}${syssep}
  srcpre=${srcpre0}${datatype}
  destdir=${destpre}${srcyear}${srcday}${syssep}
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
  echo "$today $ctime: Checking Rsync Results  from $srcdir to $destdir @ $srcyear$srcday"
  echo "Please Waiting ... "
  rsync  --port=$rsyncPort --timeout=60 -auqgop --exclude="\$RECYCLE.BIN" --protocol=29  $srcdir $destdir
  chmod 777 -R $destdir
  echo "$today $ctime: Succeeded in Rsyncing $datatype data@FSO!"
  exit 0
else
  echo "$today $ctime: $procName is running..."
  exit 0
fi

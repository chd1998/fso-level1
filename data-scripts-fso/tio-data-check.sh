#!/bin/bash
#purposes: to check the local data with remote ip
#usage: usage: ./fso-data-check.sh  tio/ha srcip year(in 4 digits) monthday(in 4 digits) destdir
#example: ./fso-data-check.sh  tio 192.168.111.70 2019 0420 /lustre/data
#changlog:
#       20190419    		Release 0.1		first workinging release
#	20190426		Release 0.2 		using rsync dryrun to check data integrity

echo " "
echo "===== Welcome to FSO Data Checking System @FSO (Rev. 0.2 20190426 10:33) ====="
echo " "

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

#if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] || [[ -z $5 ]] ;then
if [ $# -ne 5 ];then
  echo "usage: ./fso-data-check.sh  tio/ha srcip destdir  year(in 4 digits) monthday(in 4 digits)"
  echo "example: ./fso-data-check.sh  tio 192.168.111.70 2019 0420 /lustre/data"
  exit 1
fi

srcpre0=${srcIP}::
srcdir=${srcpre0}${datatype}
destdir=${destdir}${sysrep}
procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`

if [ $procCmd -le 0 ];then
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
  echo "$today $ctime: Checking Syncing Results of $datatype data@FSO"
  echo "From: $srcdir:"
  echo "To  : $destdir:"
  echo "Date: $srcyear$srcday"
  echo "Checking..."
  echo "Please Waiting ... "
  rsync  --port=$rsyncPort --timeout=60 -av --dry-run --numeric-ids --exclude="\$RECYCLE.BIN" --protocol=29  $srcdir $destdir
  destsize=`du -sh $destdir`
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime1: Succeeded in Checking Syncing $datatype data@FSO!"
  echo "        Dest size: $destsize"
  echo "        Time used: $ctime to $ctime1"
  exit 0
else
  echo "$today $ctime: $procName is running..."
  exit 0
fi

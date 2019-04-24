#!/bin/bash
#author: chen dong @fso
#purposes: manually syncing data in specified year(eg., 2019...) from remoteip to local lustre storage via wget over ftp
#usage:  ./tio-copy.sh year(4 digits)
#example: ./tio-copy.sh 2019
#changlog: 
#      	  20190420      first prototype release 0.1
#      	  20190421    	fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
#         20190423      fix errors, release 0.3

procName="wget"
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"
destpre0="/lustre/data"
srcpre0="ftp://192.168.111.120"
srcyear=%1
#srcmonthday=%2

if [[ -z $1 ]]  ;then
  echo "Use this script to copy data of year specified to /lustre/data"
  echo "Usage: ./tio-copy.sh year(4 digits)"
  echo "Example: ./tio-copy.sh 2019"
  exit 1
fi

datatype="TIO"
remotePort="21"
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

echo " "
echo "===== Welcome to Data Archiving System@FSO! ======0 "
echo "          Relase 0.3     20190423 16:07     "
echo "   Copy the TiO data from SSD to lustre manually "
echo " "
procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
if [ $procCmd -le 0 ];then
  destdir=${destpre0}${syssep}${srcyear}${syssep}
  srcdir=$srcpre0

  if [ ! -d "$destdir" ]; then
    mkdir $destdir
  else
    echo "$destdir already exist!"
  fi
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: Syncing $datatype data@FSO..."
  echo "From: $srcdir "
  echo "To  : $destdir "
  echo "Please Waiting ... "
  #read
  cd $destdir
  wget --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=tio --ftp-password=ynao246135 --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob $srcdir
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  if [ $? -ne 0 ];then
    echo "$todday $ctime1: Syncing $datatype Data@FSO Failed!"
    cd /home/chd/
    exit 1
  fi

  ctime1=`date --date='0 days ago' +%H:%M:%S`
  #chmod 777 -R $destdir
  echo "$today $ctime1: Succeeded in Syncing $datatype data@FSO!"
  echo "Time used: $ctime to  $ctime1"
  rm -rf $lockfile
  cd /home/chd/
  exit 0
else
  echo "$today $ctime: $procName  is running..."
  echo "              PID: $pid                    "
  exit 0
fi


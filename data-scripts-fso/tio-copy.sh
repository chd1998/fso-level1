#!/bin/bash
#author: chen dong @fso
#purposes: manually syncing TIO data in specified year(eg., 2019...) from remoteip to local lustre storage via lftp
#usage:  ./tio-copy.sh year(4 digits) monthday(4 digits)
#example: ./tio-copy.sh 2019 0603
#changlog: 
#      	 20190420      	Release 0.1	first prototype release 0.1
#      	 20190421	Release 0.2	fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
#        20190423      	Release 0.3	fix errors
#	 20190426	Release 0.4	fix errors
#        20190428       Release 0.5 	add monthday to the src dir
# 	 20190603	Release 0.6     using lftp instead of wget
trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    #umount $dev
    exit 1
}

procName="wget"
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"
destpre0="/lustre/data"
srcpre0="ftp://192.168.111.120"
srcyear=$1
srcmonthday=$2

if [ $# -ne 2 ]  ;then
  echo "Use this script to copy TIO data of year month day specified on remote host to /lustre/data mannually"
  echo "Usage: ./tio-copy.sh year(4 digits)  monthday(4 digits)"
  echo "Example: ./tio-copy.sh 2019 0427"
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
echo "  ===== Welcome to TIO Data Copying System@FSO! =====   "
echo "                   tio-copy.sh                          "
echo "          Relase 0.6     20190603 11:36                 "
echo "  Copy the TiO data from remote SSD to lustre manually  "
echo " "
procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
if [ $procCmd -le 0 ];then
  destdir=${destpre0}${syssep}${srcyear}${syssep}
  srcdir=${srcpre0}${syssep}${srcyear}${srcmonthday}${syssep}

  if [ ! -d "$destdir" ]; then
    mkdir $destdir
  else
    echo "$destdir already exist!"
  fi
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: Copying $datatype data@FSO..."
  echo "                   From: $srcdir "
  echo "                   To  : $destdir "
  echo "                   Please Waiting ... "
#  read
  cd $destdir
  #wget --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=tio --ftp-password=ynao246135 --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob $srcdir
  lftp -u $user,$password -e "mirror --ignore-time --allow-suid --continue --exclude /\$RECYCLE.BIN/$ --exclude /System Volume Information/$ --parallel=33  / .; quit" $srcdir 
  if [ $? -ne 0 ];then
    ctime1=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime1: Failed in Syncing Data from $srcdir to $destdir"
    cd /home/chd
    exit 1
  fi

  targetdir=${destdir}${datatype}
  filenumber=`ls -lR $targetdir | grep "^-" | wc -l`
  srcsize=`du -sh $targetdir`
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  #chmod 777 -R $destdir

  echo "$today $ctime1: Succeeded in Syncing $datatype data@FSO!"
  echo " Synced file No. : $filenumber"
  echo " Synced data size: $srcsize"
  echo "        Time used: $ctime to  $ctime1"

  rm -rf $lockfile
  cd /home/chd/
  exit 0
else
  echo "$today $ctime: $procName  is running..."
  echo "              PID: $pid                    "
  exit 0
fi


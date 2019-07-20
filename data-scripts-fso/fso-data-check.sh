#!/bin/bash
#author: chen dong @fso
#purposes: manually syncing TIO/HA data in specified date(eg., 2019 0519...) from remoteip to local lustre storage via lftp
#usage:  ./fso-data-check.sh year(4 digits)  monthday(4 digits) TIO/HA user password
#example: ./fso-data-check.sh 2019 0519 TIO tio ynao246135
#changlog: 
#      	 20190420      	Release 0.1	first prototype release 0.1
#      	 20190421	      Release 0.2	fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
#        20190423      	Release 0.3	using lftp instead of rsync

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
remoteport="21"




if [ $# -ne 5 ]  ;then
  echo "Use this script to copy TIO data of year month day specified on remote host to /lustre/data mannually"
  echo "Usage: ./tio-copy.sh year(4 digits)  monthday(4 digits) TIO/HA user password"
  echo "Example: ./tio-copy.sh 2019 0427 TIO tio ynao246135"
  exit 1
fi
srcyear=$1
srcmonthday=$2
datatype=$3
user=$4
password=$5

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
echo "  ===== Welcome to FSO Data Archiving System@FSO! =====   "
echo "                   fso-data-check.sh                          "
echo "          Relase 0.3     20190519 07:25                 "
echo "  check the  data from remote ip to lustre manually  "
echo " "
procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
if [ $procCmd -le 0 ];then
  destdir=${destpre0}${syssep}${srcyear}${syssep}
  srcdir=${srcpre0}:${remoteport}${syssep}${srcyear}${srcmonthday}${syssep}

  if [ ! -d "$destdir" ]; then
    mkdir $destdir
  else
    echo "$destdir already exist!"
  fi
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: Checking $datatype data@FSO..."
  echo "                   From: $srcdir "
  echo "                   To  : $destdir "
  echo "                   Please Wait ... "
#  read
  cd $destdir
  lftp -u $user,$password -e "mirror --ignore-time --no-perms --continue --just-print --exclude /\$RECYCLE.BIN/$   --parallel=20  / . ;quit" $srcdir
  #wget --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=tio --ftp-password=ynao246135 --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob $srcdir

   if [ $? -ne 0 ];then
    ctime1=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime1: Failed in Syncing Data from $srcdir to $destdir"
    cd /home/chd
    exit 1
  fi

  targetdir=${destdir}${srcyear}${srcmonthday}${syssep}${datatype}
  filenumber=`ls -lR $targetdir | grep "^-" | wc -l`
  srcsize=`du -sm $targetdir | awk '{print $1}'`
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  #chmod 777 -R $destdir

  echo "$today $ctime1: Succeeded in Checking $datatype data@FSO!"
  echo "           Checked: $filenumber file(s)"
  echo "           Checked: $srcsize MB"
  echo "        Time used: $ctime to  $ctime1"

  rm -rf $lockfile
  cd /home/chd/
  exit 0
else
  echo "$today $ctime: $procName  is running..."
  echo "              PID: $pid                    "
  exit 0
fi


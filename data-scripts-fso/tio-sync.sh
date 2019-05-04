#!/bin/bash
#author: chen dong @fso
#purposes: periodically syncing data from remoteip to local lustre storage via wget
#usage:  run in crontab every 15 mins.  from 08:00-20:00
#example: none
#changlog: 
#      	20190420	release 0.1
#      	20190421    	release 0.2	fix bugs,using pid as lock to prevent script from multiple starting
#	20190427	release 0.3     sync only today's data

procName="wget"
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"
destpre0="/lustre/data"
srcpre0="ftp://192.168.111.120"
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
echo "===== Welcome to Data Archiving System @ FSO! ====="
echo "                  tio-sync.sh                      "
echo "          (Release 0.3 20190427 10:09)             "
echo "                                                   "
echo "                $today $ctime                      "
echo "==================================================="
echo " "
procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
if [ $procCmd -le 0 ];then
  destpre=${destpre0}${syssep}${cyear}${syssep}
  destdir=${destpre}${today}${syssep}
#  echo "$destdir"
#  read
  srcdir=${srcpre0}${syssep}${today}${syssep}

  if [ ! -d "$destdir" ]; then
    mkdir $destdir
  else
    echo "$destdir already exist!"
  fi
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: Syncing $datatype data @ FSO..."
  echo "From: $srcdir "
  echo "To  : $destdir "
  echo "Please Waiting ... "
  #read
  cd $destpre
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  wget -o /home/chd/log/wget.log --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=tio --ftp-password=ynao246135 --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob --preserve-permissions $srcdir
  #ctime1=`date --date='0 days ago' +%H:%M:%S`
  if [ $? -ne 0 ];then
    echo "$todday $ctime1: Syncing $datatype Data @ FSO Failed!"
    cd /home/chd/
    exit 1
  fi
  targetdir=${destdir}${datatype}
  filenumber=`ls -lR $targetdir | grep "^-" | wc -l`
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  #chmod 777 -R $targetdir
  targetsize=`du -sm $targetdir|awk '{print $1}'`
  #cursize=`du -sm $cdir|awk '{print $1}'`
  echo "$today $ctime1: Succeeded in Syncing $datatype data @ FSO!"
  echo " Synced file No. : $filenumber file(s)"
  echo " Synced data size: $targetsize MB "
  echo " Time used       : $ctime to  $ctime1"
  rm -rf $lockfile
  cd /home/chd/
  exit 0
else
  echo "$today $ctime: $procName  is running..."
  echo "              PID: $pid                    "
  exit 0
fi


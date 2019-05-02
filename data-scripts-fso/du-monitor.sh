#!/bin/bash
#monitor the size of dest dir every 10 secs. 
#usage: ./du-monitor.sh yourdir delaytime(in secs.)
#example: ./du-monitor.sh /lustre/data/tmp 10
#press ctrl-c to break the script

trap 'onCtrlC' INT
function onCtrlC(){
    echo 'ctrl-c'
    exit 1
}

if [ $# -ne 2 ];then
  echo "usage: ./du-monitor.sh /youdirhere/ delaytime(in secs.)"
  echo "example: ./du-monitor.sh /lustre/data/tmp/ 0"
  echo "press ctrl-c to break!"
  exit 0
fi

cdir=$1
delaytime=$2

if [ ! -d "$cdir" ];then
  echo "Dest Dir: $cdir     doesn't exist...."
  echo "Please check..."
  exit 0
fi

#destdir=${cyear}/${cyear}${cmonthday}/${cdatatype}
echo "Please wait..."
while true
do 
  today=`date --date='0 days ago' +%Y%m%d`
  ctime=`date --date='0 days ago' +%H:%M:%S`
  cursize=`du -sm $cdir|awk '{print $1}'`
  curdir=`du -sm $cdir|awk '{print $2}'`
  filenumber=`ls -lR $curdir | grep "^-" | wc -l`
  echo "$today $ctime:"
  echo "$curdir --> $filenumber file(s)"
  echo "$curdir --> $cursize MB"
  sleep $delaytime
done

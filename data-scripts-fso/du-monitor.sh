#!/bin/bash
#monitor the size of dest dir every 10 secs. 
#usage: ./du-realtime.sh year monthday datatype
#example: ./du-realtime.sh 2019 0426 TIO
#press ctrl-c to break the script

trap 'onCtrlC' INT
function onCtrlC(){
    echo 'ctrl-c'
    exit 1
}

if [ $# -ne 1 ];then
  echo "usage: ./du-monitor.sh /youdirhere/"
  echo "example: ./du-realtime.sh /lustre/data/tmp/"
  echo "press ctrl-c to break!"
  exit 0
fi

cdir=$1



#destdir=${cyear}/${cyear}${cmonthday}/${cdatatype}
echo "Please wait..."
while true
do 
  today=`date --date='0 days ago' +%Y%m%d`
  ctime=`date --date='0 days ago' +%H:%M:%S`
  cursize=`du -sm $cdir|awk '{print $1}'`
  curdir=`du -sm $cdir|awk '{print $2}'`
  echo "$today $ctime:"
  echo "$curdir --> $cursize MB"
  sleep 10
done

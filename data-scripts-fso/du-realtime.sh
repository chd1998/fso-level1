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

if [ $# -ne 3 ];then
  echo "usage: ./du-realtime.sh year monthday datatype"
  echo "example: ./du-realtime.sh 2019 0426 TIO"
  echo "press ctrl-c to break!"
  exit 0
fi

cyear=$1
cmonthday=$2
cdatatype=$3

destpre="/lustre/data"


destdir=${destpre}/${cyear}/${cyear}${cmonthday}/${cdatatype}
if [ ! -d "$destdir" ];then
  echo "Dest Dir: $destdir     doesn't exist...."
  echo "Please check..."
  exit 0
fi
echo "Please wait..."
while true
do 
  today=`date --date='0 days ago' +%Y%m%d`
  ctime=`date --date='0 days ago' +%H:%M:%S`
  cursize=`du -sm $destdir|awk '{print $1}'`
  curdir=`du -sm $destdir|awk '{print $2}'`
  echo "$today $ctime:"
  echo "$curdir --> $cursize MB"
  sleep 10
done

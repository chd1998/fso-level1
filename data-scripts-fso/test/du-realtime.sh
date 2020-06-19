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



destdir=${cyear}/${cyear}${cmonthday}/${cdatatype}

while true
do 
  echo "$destdir size in MB: "
  today=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  cursize=`du -sm /lustre/data/$destdir`
  echo "$today $ctime: $cursize"
  sleep 10
done

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

if [ $# -ne 2 ];then
  echo "usage: ./du-realtime.sh destdir delay"
  echo "example: ./du-realtime.sh /home/user/data/2020/20200603/HA 10"
  echo "press ctrl-c to break!"
  exit 0
fi

destdir=$1
delaytime=$2
firsttime=1
lastsize=0
speed=0

while true
do 
  echo "For $destdir : "
  today=`date +%Y%m%d`
  today0=`date +%Y%m%d`
  ctime=`date +%H:%M:%S`
#  cursize=`du -sm $destdir`
  //latestsize=`du -sm $destdir|awk '{print $1}'`
  latestsize=`find $destdir -name *.fits -type f | xargs ls -al|awk '{sum += $5} END {print sum/(1024*1024)}'`
#  echo $firsttime
#  echo "$today $ctime: $latestsize @ $speed MB/s"
  if [ $firsttime -ne 1 ]; then
    copied=`echo "$lastsize $latestsize"|awk '{print($2-$1)}'`
    speed=`echo "$copied $delaytime"|awk '{print($1/$2)}'` 
    echo "$today $ctime : $latestsize MB"
    echo "           Copied : $copied MB  @ $speed MB/s"
  else
    echo "$today $ctime: $latestsize MB"
    firsttime=0
  fi
  lastsize=$latestsize
  sleep  $delaytime
done

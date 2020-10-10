#!/bin/bash

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    umount $dev
    exit 1
}

lockfile=/fso-cache/$(basename $0)-rpi.lock
day=$(date "+%Y-%m-%d %H:%M:%S")
lastyear=$(date -d "last-year" +%Y)
if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    exit 1
  else
    echo $$>$lockfile
  fi
else
  echo $$>$lockfile
fi

rm -rf /fso-weather-data/$lastyear/ & 
if [ $? -eq 0 ];
  then
    echo "$day:  /fso-weather-data/$lastyear/ cleaned!"
fi
wait


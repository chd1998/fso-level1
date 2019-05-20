#!/bin/bash
#procName=$1
#procCmd=`ps ef|grep -w $1|grep -v grep|wc -l`
pid=$(ps x|awk '/[r]sync/{print $1}')
#echo "${procCmd}"
#echo "\$RECYCLE.BIN"
if [ $pid -ne 0 ];then
  echo "$1 is running..."
  echo "$pid"
  exit 0
else
  echo "$1 is not  running..."
  exit 0
fi

#!/bin/sh
ping $1 -c5|grep ttl >> pt
pres=`cat pt|wc -l`
if [ $pres -ne 0 ];then
  echo "$1 is online..."
else
  echo "$1 is offline..."
fi

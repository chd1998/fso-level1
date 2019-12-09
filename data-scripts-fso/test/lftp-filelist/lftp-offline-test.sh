#!/bin/bash
#find /lustre/data/2019/20190907/TIO/  -type f  | cut -d '/' -f 5-10 > local-filelist
#lftp ftp://tio:ynao246135@192.168.111.188  -e "find /20190907/TIO && ;exit"| grep fits|cut -d '/' -f 1-9 > remote-filelist &
touch pingtmp
ping $1 -c5 |grep ttl >> pingtmp
res=`cat pingtmp|wc -l`
if [ $res -ne 0 ];then
  echo "lftp server is online!"
else
  echo "lftp server is offline!"
fi
rm -f pingtmp

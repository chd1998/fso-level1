#!/bin/bash
#kill all processes with pids inputed
#usage: ./pid-kill.sh name
#example: ./pid-kill.sh TIO
#press ctrl-c to break the script

if [ $# -ne 1 ];then
  echo "usage: ./pid-kill.sh name"
  echo "example: ./pid-kill.sh TIO"
  echo "press ctrl-c to break!"
  exit 0
fi
#get self pid
mypid=$$
echo $mypid>mypidtmp
ps -aux|grep $1|grep -v grep|awk '{print $2}'> pidtmp
#exclude self pid
awk 'NR==FNR{ a[$1]=$1 } NR>FNR{ if(a[$1] == ""){ print $1}}' mypidtmp pidtmp>pidlist
plist=`cat pidlist|wc -l`
#plist<=0 means no process found
if [ $plist -le 0 ];then
  echo "No $1 processes found!"
  exit 0
fi
cat pidlist|xargs kill
#wait $!
if [ $? -ne 0 ];then
  echo "Failed in kill $1 processes!"
  exit 1
else
  cat pidlist
  echo "$plist $1 processes killed!"
fi
rm -f pidtmp
rm -f pidlist
rm -f mypidtmp
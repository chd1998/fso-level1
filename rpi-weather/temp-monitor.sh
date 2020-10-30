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

if [ $# -ne 1 ];then
  echo "Usage: ./temp-monitor.sh delaytime"
  echo "Example: ./temp-monitor.sh 10"
  exit 1
fi

delaytime=$1

if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
#    echo "$day : $(basename $0) is running for reading temperature data of rpi2 @ FSO..."
    exit 1
  else
    echo $$>$lockfile
  fi
else
  echo $$>$lockfile
fi

temp=$(/opt/vc/bin/vcgencmd measure_temp)
day=$(date "+%Y-%m-%d %H:%M:%S")
cpup=`top -b -n 1 | grep Cpu | awk '{print $2}' | cut -f 1 -d "%"`
cpul=`uptime | awk '{print $9}' | cut -f 1 -d ','`
cputl=`vmstat -n 1 1 | sed -n 3p | awk '{print $1}'`
while :
do 
  day=$(date "+%Y-%m-%d %H:%M:%S")
  temp=$(/opt/vc/bin/vcgencmd measure_temp)
  cpup=`top -b -n 1 | grep Cpu | awk '{print $2}' | cut -f 1 -d "%"`
  cpul=`uptime | awk '{print $11}' | cut -f 1 -d ','`
  cputl=`vmstat -n 1 1 | sed -n 3p | awk '{print $1}'`
  echo "$day : $temp  cpu_usage=$cpup%   cpu_load=$cpul     cpu_task_length=$cputl">> /fso-cache/temp.dat
  sleep  $delaytime
done

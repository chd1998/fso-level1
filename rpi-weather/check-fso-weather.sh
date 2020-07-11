#!/bin/bash
#@author: chen dong 
#purpose: check wether data of fso-weather.py /home/pi/Desktop/communication/latest.csv is modified within time-standard sec. or not.   
#         If not, restart it  If not, kill the zombie process and restart it via cron
#usage: ./check-fso-weather.sh  time-standard(in sec.) delaytime(in sec.) programname
#example: ./check-fso-weather.sh 10 40 python3
#
#Change History: 
#		20200705	Release 0.1 : First working prototype 
#   20200709  Release 0.2 : logics revised!
#

waiting() {
  local pid="$1"
  taskname="$2"
  procing "$3" "$4"&
  local tmppid="$!"
  #local count="$4"
  wait $pid
#  tput rc
#  tput ed
  wctime=`date  +%H:%M:%S`
  wtoday=`date  +%Y-%m-%d`
  echo "$wtoday $wctime : $2 Task Has Done!"
#  dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#  dt1=`date +%s`
#  echo "                   Finishing..."
  kill -6 $tmppid >/dev/null 1>&2
#  echo "$dt1" > /home/chd/log/dtmp
}

procing() {
  trap 'exit 0;' 6
#  tput ed
  local count="$2"
  while [ 1 ]
  do
    #sleep 1
    ptoday=`date  +%Y-%m-%d`
    pctime=`date  +%H:%M:%S`
    echo "$ptoday $pctime : $1 in $count secs., Please Wait...   "
    sleep 1
    count=$[count-1]
  done
}

src="/fso-weather-data"
dest="/home/pi/fso-weather-data"
year=$(date "+%Y")
day=$(date "+%Y-%m-%d")
ctime=$(date "+%H:%M:%S")

if [ $# -ne 3 ]  ;then
  echo "purpose: check fso-weather.py's output data /home/pi/Desktop/communication/latest.csv is modified in time-standard sec. or not."
  echo "         If not, kill the zombie process and restart it via cron"
  echo "usage: ./check-fso-weather.sh  time-standard(in sec.) delaytime(in sec.) programname"
  echo "example: ./check-fso-weather.sh 10 40 python3"
  exit 1
fi

standtime=$1
delaytime=$2
pname=$3

#Version
pver=0.2

echo "*********************************************************************************************************************** "
#prevent script from multiple running
lockfile=/fso-cache/$(basename $0)-rpi.lock
if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    echo "$day $ctime : $(basename $0) is running..."
    exit 1
  else
    echo $$>$lockfile
  fi
else
  echo $$>$lockfile
fi

#check src dir and file
if [ ! -f $src/$year/fso-weather-$day.csv ];then
  echo "$day $ctime : $src/$year/fso-weather-$day.csv is not exist!"
  exit 1
fi
#sleep input sec.  after started
day=$(date "+%Y-%m-%d")
ctime=$(date "+%H:%M:%S")
#echo "$day $ctime : Waiting for $delaytime secs. ....."
sleep $delaytime  & 
waiting "$!" "Waiting" "Waiting for Data" "$delaytime"
#latest data file
datafile="/home/pi/Desktop/communication/latest.csv"

#check current time and  modification time of data file
#if diff>=300s, kill python3  for fso-weather.py 
Current_Timestamp=`date +%s`		# 获取当前时间的 Unix 时间戳
#File_Modified_Time=`stat -c %Y  $src/$year/fso-weather-$day.csv`	# 获取文件修改时间unix时间戳
File_Modified_Time=`sudo stat -c %Y  $datafile`
File_Time=`sudo stat -c %z  $src/$year/fso-weather-$day.csv`
Difftime=`echo "$Current_Timestamp $File_Modified_Time"| awk '{print($1-$2)}'`
#difft=`echo "$Difftime $standtime"|awk '{print($1-$2)}'`
#difft=`echo "$difft"|awk '{print sqrt($1*$1)}'`
#Difftime=`expr ${Current_Timestamp} - ${File_Modified_Timestamp}`	# 获取当前时间和文件修改时间的 Unix 时间戳时间差
#echo $Difftime
day=$(date "+%Y-%m-%d")
ctime=$(date "+%H:%M:%S")
if [ $Difftime -ge $standtime ];then	# 如果时间差大于输入时间，说明文件修改时间是在输入时间前，也就是最近输入时间内文件没有更新
  echo "$day $ctime : $datafile modified @ $File_Time"
  echo "$day $ctime : Modification time span  is $Difftime sec. >= required $standtime sec. --- Check Failed!"
  cpid=`pidof $pname`
  if [ $? -ne 0 ];then
    echo "$day $ctime : Couldn't find pid of $pname..."
    echo "                    : Skip checking... "
    echo " "
    exit 1
  else
    sudo kill -9 $cpid
    if [ $? -ne 0 ];then
      echo "$day $ctime : Failed in killing $cpid"
      exit 1
    else
      echo "$day $ctime : $cpid process killed!"
    fi
  fi
else
  echo "$day $ctime :  $datafile modified @ $File_Time"
  echo "$day $ctime : Modification time span is $Difftime sec. < required $standtime sec. --- Check Passed!"    
fi

#copy new data 
#sudo comm -23 $src/$year/fso-weather-$day.csv $dest/$year/fso-weather-$day.csv >>  $dest/$year/fso-weather-$day.csv

#sudo cp -f /fso-weather-data/$year/fso-weather-$(date "+%Y-%m-%d").csv /home/pi/fso-weather-data/$year/

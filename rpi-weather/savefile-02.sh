#!/bin/bash
#purpose: copy fso weather data from mem to SD
#usage: ./savefile-02.sh mode(0/1)
#     : 0 - today    1 - last day
#example: ./savefile-02.sh 0 
#       : ./savefile-02.sh 1
src="/fso-weather-data"
dest="/home/pi/fso-weather-data"
#year=$1
#day=$2
#year=$(date "+%Y")
#day=$(date "+%Y-%m-%d")

if [ $# -ne 1 ];then
  echo "usage: ./savefile-02.sh mode(0/1)"
  echo "example: ./savefile-02.sh 0"
  echo "example: ./savefile-02.sh 1"
  exit 0
fi

mode=$1
if [ $mode -eq 0 ];then
  year=$(date "+%Y")
  day=$(date "+%Y-%m-%d")
else
  year=$(date "+%Y")
  day=$(date "+%Y-%m-%d" -d "-1day")
fi

#day=$1
#year=`echo $day|cut -d '-' -f 1`

#prevent script from multiple running
lockfile=/fso-cache/$(basename $0)-rpi.lock
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

#check src & dest, in dir and file
if [ ! -d $src/$year ]; then
  mkdir -p -m 777 $src/$year
fi
if [ ! -f $src/$year/fso-weather-$day.csv ];then
  echo "source file: $src/$year/fso-weather-$day.csv is not exist!"
  exit 1
fi

if [ ! -d $dest/$year ]; then
  mkdir -p -m 777 $dest/$year
fi
if [ ! -f $dest/$year/fso-weather-$day.csv ];then
  touch $dest/$year/fso-weather-$day.csv
fi

#copy new data 
sudo comm -23 $src/$year/fso-weather-$day.csv $dest/$year/fso-weather-$day.csv >>  $dest/$year/fso-weather-$day.csv

#sudo cp -f /fso-weather-data/$year/fso-weather-$(date "+%Y-%m-%d").csv /home/pi/fso-weather-data/$year/

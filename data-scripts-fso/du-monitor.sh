#!/bin/bash
#monitor the size of dest dir every 10 secs. 
#usage: ./du-monitor.sh yourdir delaytime(in secs.)
#example: ./du-monitor.sh /lustre/data/tmp 10
#press ctrl-c to break the script

trap 'onCtrlC' INT
function onCtrlC(){
    echo 'ctrl-c'
    exit 1
}

if [ $# -ne 2 ];then
  echo "usage: ./du-monitor.sh /youdirhere/ delaytime(in secs.)"
  echo "example: ./du-monitor.sh /lustre/data/tmp/ 10"
  echo "press ctrl-c to break!"
  exit 0
fi

cdir=$1
delaytime=$2

if [ ! -d "$cdir" ];then
  echo "Dest Dir: $cdir     doesn't exist...."
  echo "Please check..."
  exit 0
fi
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
echo " "
echo "$today $ctime : Counting the file numbers &  size in $cdir"
echo "                    Please wait..."
echo "                    Press ctrl-c to break! "
echo " "
sdata=`du -sm $cdir|awk '{print $1}'`
filenumber=`ls -lR $curdir | grep "^-" | wc -l`
#sleep $delaytime
ctime=`date --date='0 days ago' +%H:%M:%S`
while true
do 
#  ctime=`date --date='0 days ago' +%H:%M:%S`
  t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  cursize=`du -sm $cdir|awk '{print $1}'`
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  curdir=`du -sm $cdir|awk '{print $2}'`
  edata=$cursize
  ddata=$((edata-sdata))
  dtime=`echo "$t1 $t2"|awk '{print($2-$1)}'`
  if [ $dtime -eq 0 ];then 
    dtime=1
  fi
  speed=`echo "$sdata $edata $dtime"|awk '{print(($2-$1)/$3)}'`
  filenumber1=`ls -lR $curdir | grep "^-" | wc -l`
  dfile=$((filenumber1-filenumber))
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3 : $curdir"    
  echo "Start with file No. : $filenumber file(s)"
  echo "          file size : $sdata MB  "
  echo "  End with file No. : $filenumber1 file(s)"
  echo "          file size : $cursize MB"
  echo "             Synced : $dfile file(s)"
  echo "             Synced : $ddata MB"
  echo "          Time Used : $dtime secs."
  echo "            @ speed : $speed MB/sec"
  echo "               From : $ctime "
  echo "                 To : $ctime1"
  echo "            Press ctrl-c to break! "
  echo "  "
  filenumber=$filenumber1
  sdata=$edata 
  sleep $delaytime
  ctime=$ctime1
done

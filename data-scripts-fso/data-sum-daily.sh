#!/bin/bash
#author: chen dong @fso
#purposes: summerize data file number and size(MiB) daily with regard to datatype
#
#changlog: 
#       20200928    Release 0.1.0     first working version 
#       20201025    Release 0.1.1     add observation time


cyear=`date  +%Y`
today=`date  +%Y%m%d`
today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
syssep="/"

if [ $# -ne 5 ];then
  echo "Usage: ./data-sum.sh destdir year monthday datatype(TIO or HA) mail(0-not send/1-send)"
  echo "Example: ./data-sum-daily.sh  /lustre/data 2020 0928 TIO 1"
  echo "         ./data-sum-daily.sh  /lustre/data 2020 0928 HA 0"
  exit 1
fi

progpre=$1
year=$2
monthday=$3
datatype=$4
mailornot=$5

pver=0.1
num=0
size=0.0
homepre=/home/chd/data-info
targetdir=$progpre/$year/$year$monthday/$datatype
suminfo=$homepre/$year/$datatype-$year-$monthday.sum
sumdir=$homepre/$year
device="lustre"
if [ ! -d "$sumdir" ]; then
  mkdir -m 777 -p $sumdir
fi
today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
cd $targetdir
echo "$today0 $ctime : Start Counting $year$monthday $datatype @$device File Numbers & Size..."
num=`find ./ -name *.fits -type f | wc -l`
if [ $num -gt "0" ];then
  size=`find $targetdir -name *.fits -type f | xargs ls -I {} -al|awk '{sum += $5} END {print sum/(1000*1024*1024)}'` 
fi

today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
echo "$today0 $ctime : Start Calculating  $year$monthday $datatype @$device Observing Time..."
cd $targetdir
start=`find ./ -name *.fits -type f | stat *|grep Change|awk '{print $2 " " $3}'| sort |head -n +1`
end=`find ./ -name *.fits -type f | stat *|grep Change|awk '{print $2 " " $3}'| sort |tail -n -1`
#touch filetime-00
#for i in `find $targetdir  -name "*.fits" -type f`; do
#  echo $i
#  stat $i|grep Change|awk '{print $2 " " $3}'>> filetime-00
#done
#sort  filetime-00 > filetime-00-sorted
#start=`head -n +1 filetime-00-sorted`
#end=`tail -n -1 filetime-00-sorted`
s=`date -d "$start" +%s`
e=`date -d "$end" +%s`
interval=`echo "$s $e"|awk '{print(($2-$1)/3600)}'`

today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
echo "$year$monthday   $num             $size         $start              $end               $interval" > $suminfo
if [ $mailornot -eq "1" ];then 
    echo "$today0 $ctime : Send Summary  for $year$monthday $datatype @$device to Users..."
    mail -s "Summary of $year$monthday $datatype @$device" chd@ynao.ac.cn < $suminfo
fi
rm -f filetime-00
rm -f filetime-00-sorted
today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
echo "$today0 $ctime : All Summary Tasks for $year$monthday $datatype @$device Ended..."

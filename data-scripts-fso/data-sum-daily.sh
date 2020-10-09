#!/bin/bash
#author: chen dong @fso
#purposes: summerize data file number and size(MiB) daily with regard to datatype
#
#changlog: 
#       20200928    Release 0.1     first working version 


cyear=`date  +%Y`
today=`date  +%Y%m%d`
today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
syssep="/"

if [ $# -ne 4 ];then
  echo "Usage: ./data-sum.sh destdir year monthday datatype(TIO or HA)"
  echo "Example: ./data-sum.sh  /lustre/data 2020 0928 TIO"
  echo "         ./data-sum.sh  /lustre/data 2020 0928 HA"
  exit 1
fi

progpre=$1
year=$2
monthday=$3
datatype=$4

pver=0.1
num=0
size=0.0
homepre=/home/chd/data-info
targetdir=$progpre/$year/$year$monthday/$datatype
suminfo=$homepre/$year/$datatype-$year-$monthday.sum
targetdir=$homepre/$year
if [ ! -d "$targetdir" ]; then
  mkdir -m 777 -p $targetdir
fi
num=`find $targetdir -name *.fits -type f | wc -l`
if [ $num -gt "0" ];then
  size=`find $targetdir -name *.fits -type f | xargs ls -I {} -al|awk '{sum += $5} END {print sum/(1000*1024*1024)}'` 
fi
echo "$year$monthday   $num             $size" > $suminfo
mail -s "Summary of $year$monthday $datatype@lustre" chd@ynao.ac.cn < $suminfo



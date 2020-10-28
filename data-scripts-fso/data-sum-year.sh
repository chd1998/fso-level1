#!/bin/bash
#author: chen dong @fso
#purposes: Annual Report of Data Info with regard to datatype @fso
#
#changlog: 
#       20200928    Release 0.1.0     first working version 
#       20201025    Release 0.1.1     add observation time


cyear=`date  +%Y`
today=`date  +%Y%m%d`
today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
syssep="/"

if [ $# -ne 2 ];then
  echo "Usage: ./data-sum.sh destdir year datatype(TIO or HA)"
  echo "Example: ./data-sum-year.sh   2020  TIO"
  echo "         ./data-sum-year.sh   2020  HA"
  exit 1
fi

year=$1
datatype=$2

pver=0.1.1
num=0
size=0.0
obstime=0.0
homepre=/home/chd/data-info
suminfo=$homepre/$datatype-$year@fso.info
targetdir=$homepre/$year
if [ ! -d "$targetdir" ]; then
  echo "$targetdir is not exist, pls check..."
  exit 1
fi
cd $targetdir
num=`cat $datatype*.sum|awk '{sum += $2} END {print sum}'`
size=`cat $datatype*.sum|awk '{sum += $3} END {print sum}'`
obstime=`cat $datatype*.sum|awk '{sum += $8} END {print sum/3600}'`
echo "$year $datatype Summary @fso" >$suminfo
echo "Date       No.          Size(MiB)           Total Obs. Time(hrs)" >$suminfo
echo "*****************************************************">>$suminfo
cat $datatype*.sum | awk '{print $1"      "$2"           "$3"             "$8}' >> $suminfo
echo "*****************************************************">>$suminfo
echo "Sum:       $num          $size               $obstime" >> $suminfo
mail -s "$year Annual Summary of $datatype @fso" chd@ynao.ac.cn < $suminfo
#mail -s "$year Annual Summary of $datatype @fso" nvst_obs@ynao.ac.cn < $suminfo


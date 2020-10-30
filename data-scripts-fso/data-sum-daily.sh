#!/bin/bash
#author: chen dong @fso
#purposes: summerize data file number and size(MiB) daily with regard to datatype
#
#changlog: 
#       20200928    Release 0.1.0     first working version 
#       20201025    Release 0.1.1     add observation time and revised
#       20201028    Release 0.1.2     observation time logics revised


cyear=`date  +%Y`
today=`date  +%Y%m%d`
today0=`date  +%Y%m%d`
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

pver=0.1.2
num=0
size=0.0
interval=0.0
start="null"
end="null"
homepre=/home/chd/data-info
targetdir=$progpre/$year/$year$monthday/$datatype
sumdir=$homepre/$year
suminfo=$sumdir/$datatype-$year-$monthday.sum

device="lustre"
dataprefix=`echo $datatype|echo ${datatype:0:1}`
t0=`date  +%Y%m%d`
d0=`date +%H:%M:%S`
dt0=`date +%s`
echo "$today0 $ctime : Start  $year$monthday $datatype Data @$device Summerizing, Pls Wait..."
if [ ! -d "$sumdir" ]; then
  mkdir -m 777 -p $sumdir
fi

if [ -d "$targetdir" ]; then
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  cd $targetdir
  #echo "$today0 $ctime : Start Counting $year$monthday $datatype @$device File Numbers & Size..."
  num=`find ./ -name $dataprefix*.fits -type f | wc -l`
  if [ $num -gt "0" ];then
    size=`find ./ -name $dataprefix*.fits -type f | xargs ls -I {} -al|awk '{sum += $5} END {print sum/(1000*1024*1024)}'` 
  fi
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  #echo "$today0 $ctime : Start Calculating  $year$monthday $datatype @$device Observing Time..."
  cd $targetdir
  #find ./   -path "*redata*" -o -path "*dark*" -o -path "*FLAT*"  -prune -o -type f -name "$dataprefix*.fits" -print >$datatype-$year-$monthday-flist
  #sort $datatype-$year-$monthday-flist>$datatype-$year-$monthday-flist-sorted
  #start=`head -n +1 $datatype-$year-$monthday-flist-sorted | xargs stat |grep Change|awk '{print $2 " " $3}'`
  #end=`tail -n -1 $datatype-$year-$monthday-flist-sorted | xargs stat |grep Change|awk '{print $2 " " $3}'`
  #get earliest file's time
  start=`find ./   -path "*redata*" -o -path "*dark*" -o -path "*FLAT*"  -prune -o -type f -name "$dataprefix*.fits" -print |xargs ls -ltr 2>/dev/null|head -n +1|awk '{print($9)}'|xargs stat|grep Change|awk '{print( $2" "$3)}'`
  #get latest file's time
  end=`find ./  -path "*redata*" -o -path "*dark*" -o -path "*FLAT*"  -prune -o -type f -name "$dataprefix*.fits" -print |xargs ls -lt 2>/dev/null|head -n +1|awk '{print($9)}'|xargs stat|grep Change|awk '{print( $2" "$3)}'`
  s=`date -d "$start" +%s`
  e=`date -d "$end" +%s`
  interval=`echo "$s $e"|awk '{print(($2-$1)/3600)}'`

  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  echo "$year$monthday   $num             $size         $start              $end               $interval" > $suminfo
  if [ $mailornot -eq "1" ];then 
    echo "$today0 $ctime : Send Summary  for $year$monthday $datatype @$device to Users..."
    mail -s "Summary of $year$monthday $datatype @$device" nvst_obs@ynao.ac.cn < $suminfo
    mail -s "Summary of $year$monthday $datatype @$device" chd@ynao.ac.cn < $suminfo
  fi
  rm -f $datatype-$year-$monthday-flist
  rm -f $datatype-$year-$monthday-flist-sorted
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  t1=`date  +%Y%m%d`
  d1=`date +%H:%M:%S`
  dt1=`date +%s`
  dt=`echo $dt0 $dt1|awk '{print($2-$1)'}`
  echo "$today0 $ctime : All Summary Tasks for $year$monthday $datatype @$device Ended..."
  echo "               in : $dt secs."
else
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  echo "$today0 $ctime : $targetdir doesn't exist, pls check..."
fi


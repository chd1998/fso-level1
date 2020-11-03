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
num="00000000"
size="0000000.0000"
interval="0000.000000"
start="0000-00-00 00:00:00.000000000"
end="0000-00-00 00:00:00.000000000"

homepre=/home/chd/data-info
targetdir=$progpre/$year/$year$monthday/$datatype
sumdir=$homepre/$year
suminfo=$sumdir/$datatype-$year-$monthday.sum

device="lustre"
dataprefix=`echo $datatype|echo ${datatype:0:1}`
t0=`date  +%Y%m%d`
d0=`date +%H:%M:%S`
dt0=`date +%s`
#echo "$today0 $ctime : Start  $year$monthday $datatype Data @$device Summerizing, Pls Wait..."
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
    num=`printf "%08d" $num`
    size=`printf "%012.4f" $size`
  else
    num="00000000"
    size="0000000.0000"
    interval="0000.000000"
  fi
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  #echo "$today0 $ctime : Start Calculating  $year$monthday $datatype @$device Observing Time..."
  cd $targetdir
  start=`find ./   -path "*redata*" -o -path "*dark*" -o -path "*FLAT*"  -prune -o -type f -name "$dataprefix*.fits" -print |xargs ls -ltr 2>/dev/null|head -n +1|awk '{print($9)}'|xargs stat|grep Change|awk '{print( $2" "$3)}'`
  if [ -z "$start" ]; then
    start="19700101 08:00:00.000"
    s=`date -d "$start" +%s`
    start="0000-00-00 00:00:00.000000000"
  else
    s=`date -d "$start" +%s`
  fi
  end=`find ./  -path "*redata*" -o -path "*dark*" -o -path "*FLAT*"  -prune -o -type f -name "$dataprefix*.fits" -print |xargs ls -lt 2>/dev/null|head -n +1|awk '{print($9)}'|xargs stat|grep Change|awk '{print( $2" "$3)}'`
  if [ -z "$end" ]; then
    end="19700101 08:00:00.000"
    e=`date -d "$end" +%s`
    end="0000-00-00 00:00:00.000000000"
  else
    e=`date -d "$end" +%s`
  fi
  
  interval=`echo "$s $e"|awk '{print(($2-$1)/3600)}'`
  interval=`printf "%011.6f" $interval`

  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  echo "$year$monthday   $num              $size               $start                       $end               $interval " > $suminfo
  if [ $mailornot -eq "1" ];then 
    echo "$today0 $ctime : Send Summary  for $year$monthday $datatype @$device to Users..."
    echo "                      $datatype Data Summary $year$monthday @fso                                  "> ./mailtmp
    echo "Date       Nums.                 Size(GiB)                  StartTime                                           EndTime                                     Obs. Time(hrs)" >>./mailtmp
    echo "**********************************************************************************************************************************************************************************">> ./mailtmp
    cat $suminfo >> ./mailtmp
    mail -s "Summary of $year$monthday $datatype @$device" nvst_obs@ynao.ac.cn < ./mailtmp
    mail -s "Summary of $year$monthday $datatype @$device" chd@ynao.ac.cn < ./mailtmp
  fi
  rm -f $datatype-$year-$monthday-flist
  rm -f $datatype-$year-$monthday-flist-sorted
  rm -f ./mailtmp
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  t1=`date  +%Y%m%d`
  d1=`date +%H:%M:%S`
  dt1=`date +%s`
  dt=`echo $dt0 $dt1|awk '{print($2-$1)'}`
  #sleep 1
  echo "$today0 $ctime : All Summary Tasks for $year$monthday $datatype @$device Ended..."
  echo "               in : $dt secs."
else
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  echo "$today0 $ctime : $targetdir doesn't exist, pls check..."
fi


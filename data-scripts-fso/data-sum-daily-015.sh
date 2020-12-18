#!/bin/bash
#author: chen dong @fso
#purposes: summerize data file number and size(MiB) daily with regard to datatype
#
#changlog: 
#       20200928    Release 0.1.0     first working version 
#       20201025    Release 0.1.1     add observation time and revised
#       20201028    Release 0.1.2     observation time logics revised
#       20201108    Release 0.1.3     exclude reduced, flat and dark data from counting
#	      20201203    Release 0.1.4     add obs log

cyear=`date  +%Y`
today=`date  +%Y%m%d`
today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
syssep="/"

if [ $# -ne 5 ];then
  echo "Usage: ./data-sum.sh destdir year monthday datatype(TIO or HA) mail(0-not send/1-send)"
  echo "Example: ./data-sum-daily-xxx.sh  /lustre/data 2020 0928 TIO 1"
  echo "         ./data-sum-daily-xxx.sh  /lustre/data 2020 0928 HA 0"
  exit 1
fi

progpre=$1
year=$2
monthday=$3
datatype=$4
mail=$5

pver=0.1.3
num="00000000"
size="0000000.0000"
interval="0000.000000"
start="0000-00-00 00:00:00.000000000"
end="0000-00-00 00:00:00.000000000"

homepre=/home/chd/data-info
mypre=/home/chd
tmppre=/home/chd/tmp
targetdir=$progpre/$year/$year$monthday/$datatype
sumdir=$homepre/$year
suminfo=$sumdir/$datatype-$year-$monthday.sum
obslog=$homepre/$year/$datatype-obs-log-$year$monthday
filelist=$tmppre/$datatype-$year-$monthday-list
stime=$tmppre/start-$datatype-$year$monthday-time
etime=$tmppre/end-$datatype-$year$monthday-time
obstime=$tmppre/obs-$datatype-$year$monthday-time

device="lustre"
site="fso"
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
  #cd $targetdir
  if [ $mail -eq "1" ];then
    echo "$today0 $ctime : Start Counting $year$monthday $datatype @$device File Numbers & Size..."
  fi 
  num=`find $targetdir/   -type f -name ''*.fits'' -not -path "*redata*" | wc -l`
  if [ $num -gt "0" ];then
    size=`find $targetdir/  -type f -name ''*.fits'' -not -path "*redata*"  | xargs ls -I {} -al|awk '{sum += $5} END {print sum/(1000*1024*1024)}'`
    if [ -f $obstime ];then
        interval=`cat $obstime`
    else
        $mypre/obs-log-info-014.sh  $progpre $year $monthday $datatype 0
        interval=`cat $obstime`
    fi
    num=`printf "%08d" $num`
    size=`printf "%012.4f" $size`
    interval=`printf "%011.6f" $interval`
    start=`cat $stime`
    end=`cat $etime`
  else
    num="00000000"
    size="0000000.0000"
    interval="0000.000000"
    start="0000-00-00 00:00:00.000000000"
    end="0000-00-00 00:00:00.000000000"
  fi

  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  DATATYPE=`printf "%3s" $datatype`
  echo "$DATATYPE           $year$monthday   $num              $size               $start                       $end               $interval " > $suminfo
  #echo "$DT           $year$monthday   $num              $size               $start                       $end               $interval " 
  if [ $mail -eq "1" ];then 
    echo "$today0 $ctime : Send Summary  for $year$monthday $datatype @$device to Users..."
    echo "                      $datatype Data Summary - $year$monthday @fso                                  "> $tmppre/$datatype-mailtmp
    echo "DataType      Date       Nums.                 Size(GiB)                  StartTime                                           EndTime                                     Obs. Time(hrs)" >>$tmppre/$datatype-mailtmp
    echo "******************************************************************************************************************************************************************************************">> $tmppre/$datatype-mailtmp
    cat $suminfo >> $tmppre/$datatype-mailtmp
    echo "******************************************************************************************************************************************************************************************">> $tmppre/$datatype-mailtmp
    today0=`date  +%Y%m%d`
    ctime=`date  +%H:%M:%S`
    echo "$today0 $ctime : Add Obs. Log..."
    if [ -f "$obslog" ];then
      cat $obslog >> $tmppre/$datatype-mailtmp
    else 
      /home/chd/obs-log-info-013.sh $progpre $year $monthday $datatype 0
      cat $obslog >> $tmppre/$datatype-mailtmp
    fi        
    mail -s "Summary of $year$monthday $datatype @$device" nvst_obs@ynao.ac.cn < $tmppre/$datatype-mailtmp
    mail -s "Summary of $year$monthday $datatype @$device" chd@ynao.ac.cn < $tmppre/$datatype-mailtmp
    mail -s "Summary of $year$monthday $datatype @$device" xiangyy@ynao.ac.cn < $tmppre/$datatype-mailtmp
    mail -s "Summary of $year$monthday $datatype @$device" yanxl@ynao.ac.cn < $tmppre/$datatype-mailtmp
    mail -s "Summary of $year$monthday $datatype @$device" xj@ynao.ac.cn < $tmppre/$datatype-mailtmp
    mail -s "Summary of $year$monthday $datatype @$device" kim@ynao.ac.cn < $tmppre/$datatype-mailtmp
    mail -s "Summary of $year$monthday $datatype @$device" lz@ynao.ac.cn < $tmppre/$datatype-mailtmp
  fi
  rm -f $datatype-$year-$monthday-flist
  rm -f $datatype-$year-$monthday-flist-sorted
  rm -f $tmppre/$datatype-mailtmp
  rm -f $filelist
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  t1=`date  +%Y%m%d`
  d1=`date +%H:%M:%S`
  dt1=`date +%s`
  dt=`echo $dt0 $dt1|awk '{print($2-$1)'}`
  #sleep 1
  if [ $mail -eq "1" ];then
    echo "$today0 $ctime : All Summary Tasks for $year$monthday $datatype @$device Ended..."
    echo "               in : $dt secs."
  fi
else
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  tput rc
  tput ed
  echo "$today0 $ctime : $targetdir doesn't exist, pls check..."
fi

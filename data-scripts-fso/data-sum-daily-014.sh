#!/bin/bash
#author: chen dong @fso
#purposes: summerize data file number and size(MiB) daily with regard to datatype
#
#changlog: 
#       20200928    Release 0.1.0     first working version 
#       20201025    Release 0.1.1     add observation time and revised
#       20201028    Release 0.1.2     observation time logics revised
#       20201108    Release 0.1.3     exclude reduced, flat and dark data from counting
#       20201203    Release 0.1.4     add obs log

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

checkmonth=${monthday:0:2}
checkday=${monthday:2:2}

pver=0.1.3
num="00000000"
size="0000000.0000"
interval="0000.000000"
start="0000-00-00 00:00:00.000000000"
end="0000-00-00 00:00:00.000000000"

homepre=/home/chd/data-info
tmppre=/home/chd/tmp
targetdir=$progpre/$year/$year$monthday/$datatype
sumdir=$homepre/$year
suminfo=$sumdir/$datatype-$year-$monthday.sum
obslog=$homepre/$year/$datatype-obs-log-$year$monthday
filelist=$tmppre/$datatype-$year-$monthday-list

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
    num=`printf "%08d" $num`
    size=`printf "%012.4f" $size`
  else
    num="00000000"
    size="0000000.0000"
    interval="0000.000000"
  fi
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  #only time before 19 on checkdate count
  find $targetdir/   -type f -name ''*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 > $tmppre/flist.tmp
  awk '{if($2<19)print $1" "$2 }' $tmppre/flist.tmp > $filelist
  #echo "$today0 $ctime : Start Calculating  $year$monthday $datatype @$device Observing Time..."
  #cd $targetdir
  #start=`find ./   -path "*redata*" -o -path "*Dark*" -o -path "*dark*" -o -path "*FLAT*"  -prune -o -type f -name $dataprefix*.fits -print |xargs ls -ltr 2>/dev/null |head -n +1|awk '{print($9)}'|xargs stat 2>/dev/null|grep Change|awk '{print($2" "$3)}'`
  #start=`find ./ -type f -name ''$dataprefix*.fits'' -not -path "*redata*"  -print |xargs ls -ltr 2>/dev/null |head -n +1|awk '{print($9)}'|xargs stat 2>/dev/null|grep Change|awk '{print($2" "$3)}'`
  start=`cat $filelist |grep $checkmonth-$checkday|head -n +1`
  if [ -z "$start" ]; then
    #start="19700101 08:00:00.000"
    #s=`date -d "$start" +%s`
    s=0
    start="0000-00-00 00:00:00.000000000"
  else
    s=`date -d "$start" +%s`
  fi
  #end=`find ./  -path "*redata*" -o -path "*Dark*" -o -path "*dark*" -o -path "*FLAT*"  -prune -o -type f -name $dataprefix*.fits -print |xargs ls -lt 2>/dev/null|head -n +1|awk '{print($9)}'|xargs stat 2>/dev/null|grep Change|awk '{print( $2" "$3)}'`
  #end=`find ./ -type f -name ''$dataprefix*.fits'' -not -path "*redata*"  -print |xargs ls -lt 2>/dev/null|head -n +1|awk '{print($9)}'|xargs stat 2>/dev/null|grep Change|awk '{print( $2" "$3)}'`
  end=` cat $filelist |sort -r|grep $checkmonth-$checkday|head -n +1`
  if [ -z "$end" ]; then
    #end="19700101 08:00:00.000"
    #e=`date -d "$end" +%s`
    e=0
    end="0000-00-00 00:00:00.000000000"
  else
    
    e=`date -d "$end" +%s`
  fi

  

  interval=`echo "$s $e"|awk '{print(($2-$1)/3600)}'`
  interval=`printf "%011.6f" $interval`
  
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
  DATATYPE=`printf "%3s" $datatype`
  num="00000000"
  size="0000000.0000"
  start="0000-00-00 00:00:00.000000000"
  end="0000-00-00 00:00:00.000000000"
  interval="0000.000000"
  echo "$DATATYPE           $year$monthday   $num              $size               $start                       $end               $interval " > $suminfo
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  tput rc
  tput ed
  echo "$today0 $ctime : $targetdir doesn't exist, pls check..."
fi

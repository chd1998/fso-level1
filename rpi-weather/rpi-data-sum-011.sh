#!/bin/bash
#author: chen dong @fso
#purposes: summerize weather data file number and size(MiB) from start to end date
#        : from start date to end date 
#changlog: 
#       20201010    Release 0.1.0     first working version 
#       20201028    Release 0.1.1     revised logics


cyear=`date  +%Y`
today=`date  +%Y%m%d`
today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
syssep="/"

if [ $# -ne 6 ];then
  echo "Usage: ./rpi-data-sum-xxx.sh datadir startyear startmonthday endyear endmonthday mail(1 mail/0-no mail)"
  echo "Example: ./rpi-data-sum-xxx.sh  /home/pi/fso-weather-data 2020 0928  2020 1001 1"
  echo "         ./rpi-data-sum-xxx.sh  /home/pi/fso-weather-data 2020 0928  2020 1001 0"
  exit 1
fi

datapre=$1
syear=$2
smonthday=$3
eyear=$4
emonthday=$5
mail=$6

num=0
size=0.0
obsday=0
<<<<<<< HEAD
stddn=12948
=======
<<<<<<< HEAD
stddn=12948
=======
<<<<<<< HEAD
stddn=17280
=======
stddn=12960
>>>>>>> e2cdcc274edbf98c530b94baf959597bbbf655ad
>>>>>>> 580674a5e5aa50a8a9485e5a4ba64f8d5a134d92
>>>>>>> 3fd0cbebf71dbd961188f928769198183c183264

snum=0
ssize=0.0
sday=0

site=fso
device=rpi-weather-station
datadir=/home/pi/fso-weather-data
progpre=/home/pi
suminfo=$datadir/$device-$site-$syear$smonthday-$eyear$emonthday.sum

if [ ! -d "$datadir" ];then
    echo "No $device data directory $datadir found, pls check....."
    exit 1
fi	


sdate=$syear$smonthday
edate=$eyear$emonthday
checkdays=$((($(date +%s -d $edate) - $(date +%s -d $sdate))/86400));
totaldays=`echo $checkdays 1|awk '{print($1+$2)}'`
today=`date  +%Y%m%d`
today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
i=0
pver=0.1.1
t0=`date +%s`
tmpdate=$sdate
echo " "
echo " "
echo "                           $device Data Summary $syear$smonthday to $eyear$emonthday @$site                                  "
echo "                                          Version $pver                                                                     "
echo "                                         $today $ctime                  "
echo "                      $device Data Summary $syear$smonthday to $eyear$emonthday @$site                                  ">$suminfo
echo "                                          Version: $pver                                                                     ">>$suminfo
echo "                                         $today $ctime                  ">>$suminfo
echo "*******************************************************************************************************"
echo "*******************************************************************************************************">>$suminfo
echo "Date         Nums.                Size(MiB)              DataLoss(%)" >>$suminfo
echo "*******************************************************************************************************">> $suminfo
while [ $i -le $checkdays ]
do
  checkdate=`date +%Y%m%d -d "+$i days $sdate"`
  checkyear=${checkdate:0:4}
  checkmonth=${checkdate:4:2}
  checkday=${checkdate:6:2}
  
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S` 
  num=0
  echo "$today0 $ctime : Start $checkdate $device Data Summerizing @fso"
  if [ -f "$datadir/$checkyear/fso-weather-$checkyear-$checkmonth-$checkday.csv" ];then
    cat $datadir/$checkyear/fso-weather-$checkyear-$checkmonth-$checkday.csv|awk '{print $2}'|cut -c2-3>./fso-weather-$checkyear-$checkmonth-$checkday-tmplist
    for line in $(cat ./fso-weather-$checkyear-$checkmonth-$checkday-tmplist)
    do
      if [ $line -ge 06 ]; then
      let num++
      fi
    done
    rm -f ./fso-weather-$checkyear-$checkmonth-$checkday-tmplist
    if [ $num -gt $stddn ]; then
      num=$stddn
    fi
    #num=`wc -l $datadir/$checkyear/fso-weather-$checkyear-$checkmonth-$checkday.csv|awk '{print $1}'` 
    size=`ls -al $datadir/$checkyear/fso-weather-$checkyear-$checkmonth-$checkday.csv|awk '{sum += $5} END {print sum/(1024*1024)}'`
  else
    num=0
    size=0.0
  fi
  if [ ! -z $num ];then
    dataloss=`echo $num $stddn|awk '{print((($2-$1)/$2)*100)}'`
  else
    dataloss=100.0
  fi
  snum=`echo $snum $num|awk '{print($1+$2)}'`
  ssize=`echo $ssize $size|awk '{print($1+$2)}'`
  lnum=`printf "%09d" $num`
  lsize=`printf "%012.6f" $size`
  ldataloss=`printf "%04.2f" $dataloss`
  echo "$today0 $ctime : $checkdate     $lnum            $lsize           $ldataloss%"
  echo "$checkdate     $lnum            $lsize           $ldataloss%">>$suminfo
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S` 
  #tput ed
  #tput rc
  let i++
  echo "                  : $i of $totaldays Day(s) Processed..."
  echo " "
done

today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
tstddn=`echo $totaldays $stddn|awk '{print($1*$2)}'`
tdataloss=`echo $snum $tstddn|awk '{print((($2-$1)/$2)*100)}'`
snum=`printf "%09d" $snum`
ssize=`printf "%012.6f" $ssize`
tdataloss=`printf "%04.2f" $tdataloss`
checkdays=`echo $checkdays|awk '{ print($1+1)}'`
checkdays=`printf "%04d" $checkdays`
sdate=$syear$smonthday
edate=$eyear$emonthday
echo "========================================================================================================"
echo "========================================================================================================">>$suminfo
echo "From          To            Num(s).          Size(MiB)             Day(s)   DataLoss(%)"
echo "From          To            Num(s).          Size(MiB)             Day(s)   DataLoss(%)">>$suminfo
echo "$sdate      $edate      $snum        $ssize          $checkdays     $tdataloss%"
echo "$sdate      $edate      $snum        $ssize          $checkdays     $tdataloss%">>$suminfo
echo "========================================================================================================"
echo "========================================================================================================">>$suminfo
t1=`date +%s`
today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
if [ $mail -eq "1" ];then 
  echo "$today0 $ctime : Send Summary of $device @$site to Users..."
  mutt -s "Summary of $device Data from $syear$smonthday to $eyear$emonthday @$site" chd@ynao.ac.cn <$suminfo
fi
dt=`echo $t0 $t1|awk '{print($2-$1)}'`
today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
echo "$today0 $ctime : $i days $device Data @$site Summerized..."
echo "             From : $sdate"
echo "               To : $edate"
echo "             Used : $dt secs."

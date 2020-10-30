#!/bin/bash
#author: chen dong @fso
#purposes: summerize data file number and size(MiB) daily with regard to datatype
#        : from start date to end date
#changlog: 
<<<<<<< HEAD
#       20201010    Release 0.1     first working version 
=======
#       20201010    Release 0.1.0     first working version 
#       20201028    Release 0.1.1     revised logics
>>>>>>> 40447c1394a70eb6b33877c9201b811984f93e0d

waiting() {
  local pid="$1"
  taskname="$2"
  procing "$3" &
  local tmppid="$!"
  wait $pid
  tput rc
  tput ed
  wctime=`date  +%H:%M:%S`
  wtoday=`date  +%Y%m%d`
  echo "$wtoday $wctime : $2 Task Has Done!"
#  dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  dt1=`date +%s`
<<<<<<< HEAD
  echo "                   Finishing...."
=======
#  echo "                   Finishing..."
>>>>>>> 40447c1394a70eb6b33877c9201b811984f93e0d
  kill -6 $tmppid >/dev/null 1>&2
  echo "$dt1" > /home/chd/log/dtmp
}

procing() {
  trap 'exit 0;' 6
  tput ed
  while [ 1 ]
  do
<<<<<<< HEAD
    sleep 1
    ptoday=`date  +%Y%m%d`
    pctime=`date  +%H:%M:%S`
    echo "$ptoday $pctime: $1, Please Wait...   "
=======
    for j in '-' '\\' '|' '/'
    do
      tput sc
      ptoday=`date  +%Y%m%d`
      pctime=`date  +%H:%M:%S`
      echo -ne  "$ptoday $pctime : $1...   $j"
      sleep 0.2
      tput rc
    done
>>>>>>> 40447c1394a70eb6b33877c9201b811984f93e0d
  done
}

cyear=`date  +%Y`
today=`date  +%Y%m%d`
today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
syssep="/"



if [ $# -ne 6 ];then
  echo "Usage: ./data-sum.sh datadir startyear startmonthday endyear endmonthday datatype(TIO or HA)"
  echo "Example: ./data-sum-missing.sh  /lustre/data 2020 0928  2020 1001 TIO"
  echo "         ./data-sum-missing.sh  /lustre/data 2020 0928  2020 1001 HA"
  exit 1
fi

datapre=$1
syear=$2
smonthday=$3
eyear=$4
emonthday=$5
datatype=$6

pver=0.1.1
num=0
size=0.0
obstime=0.0
device=lustre
homepre=/home/chd/data-info

if [ ! -d "$homepre" ];then
    mkdir -m 777 -p $homepre
fi	


sdate=$syear$smonthday
edate=$eyear$emonthday
checkdays=$((($(date +%s -d $edate) - $(date +%s -d $sdate))/86400));
today=`date  +%Y%m%d`
today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
i=0
t0=`date +%s`
tmpdate=$sdate
while [ $i -le $checkdays ]
do
    echo
    checkdate=`date +%Y%m%d -d "+$i days $sdate"`
    checkyear=${checkdate:0:4}
    checkmonthday=${checkdate:4:4}
    if [ ! -f $homepre/$checkyear/$datatype-$checkyear-$checkmonthday.sum ];then
	today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S` 
	#echo "$today0 $ctime : Start $checkdate $datatype  Data Summerizing @fso"
  /home/chd/data-sum-daily.sh $datapre $checkyear $checkmonthday $datatype 0&
	waiting "$!" "$datatype Date Summerizing on $checkdate @$device" "Summerizing $datatype Data on $checkdate @$device"
	#    echo "$i $checkdate"
    fi
    let i++
done
today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
t1=`date +%s`
dt=`echo $t0 $t1|awk '{print($2-$1)}'`
echo "$today0 $ctime : $i days $datatype Data  Summerized..."
echo "             From : $sdate"
echo "               To : $edate"
echo "             Used : $dt secs."



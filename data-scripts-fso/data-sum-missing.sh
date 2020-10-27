#!/bin/bash
#author: chen dong @fso
#purposes: summerize data file number and size(MiB) daily with regard to datatype
#        : from start date to end date
#changlog: 
#       20201010    Release 0.1.0    first working version
#       20201025    Release 0.1.1    add observation time

waiting() {
  local pid="$1"
  taskname="$2"
  procing "$3" &
  local tmppid="$!"
  wait $pid
#恢复光标到最后保存的位置
#        tput rc
#        tput ed
  wctime=`date  +%H:%M:%S`
  wtoday=`date  +%Y%m%d`
               
  echo "$wtoday $wctime : $2 Task Has Done!"
  #dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  dt1=`date +%s`
  echo "                    Finishing...."
  kill -6 $tmppid >/dev/null 1>&2
  echo "$dt1" > /home/chd/log/$(basename $0)-$datatype-sdtmp.dat
}

#   输出进度条, 小棍型
procing() {
  trap 'exit 0;' 6
  tput ed
  while [ 1 ]
  do
    sleep 1
    ptoday=`date  +%Y%m%d`
    pctime=`date  +%H:%M:%S`
    echo "$ptoday $pctime : $1, Please Wait...   "
  done
}

cyear=`date  +%Y`
today=`date  +%Y%m%d`
today0=`date  +%Y%m%d`
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

pver=0.1
num=0
size=0.0
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
tmpdate=$sdate
t0=`date  +%Y%m%d`
d0=`date +%H:%M:%S`
dt0=`date +%s`
while [ $i -le $checkdays ]
do
    echo
    checkdate=`date +%Y%m%d -d "+$i days $sdate"`
    checkyear=${checkdate:0:4}
    checkmonthday=${checkdate:4:4}
    if [ ! -f $homepre/$checkyear/$datatype-$checkyear-$checkmonthday.sum ];then
	    today0=`date  +%Y%m%d`
      ctime=`date  +%H:%M:%S` 
	    echo "$today0 $ctime : Start $checkdate $datatype  Data Sumerizing @fso"
      /home/chd/data-sum-daily.sh $datapre $checkyear $checkmonthday $datatype 0 &
	    waiting "$!" "$datatype Sumerizing" "Sumerizing $datatype Data @$checkdate"
	    #    echo "$i $checkdate"
    fi
    let i++
done
today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
t1=`date  +%Y%m%d`
d1=`date +%H:%M:%S`
dt1=`date +%s`
dt=`echo $dt0 $dt1|awk '{print($2-$1)}`
echo "$today0 $ctime : $i days $datatype Data  Sumerized..."
echo "             From : $sdate"
echo "               To : $edate"
echo "               in : $dt secs."



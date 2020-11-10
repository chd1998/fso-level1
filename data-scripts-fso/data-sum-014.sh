#!/bin/bash
#author: chen dong @fso
#purposes: summerize data file number and size(MiB) daily with regard to datatype
#        : from start date to end date 
#changlog: 
#       20201010    Release 0.1.0     first working version 
#       20201028    Release 0.1.1     revised logics
#       20201103    Release 0.1.2     unify check & report & mail
#       20201104    Release 0.1.3     add obs days
#       20201105    Release 0.1.4     deal with multiple years

waiting() {
  local pid="$1"
  taskname="$2"
  procing "$3" &
  local tmppid="$!"
  wait $pid
  #sleep 1
  tput rc
  tput ed
  wctime=`date  +%H:%M:%S`
  wtoday=`date  +%Y%m%d`
  #echo "$wtoday $wctime : $2 Task Has Done!"
#  dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  dt1=`date +%s`
#  echo "                   Finishing..."
  kill -6 $tmppid >/dev/null 1>&2
  echo "$dt1" > /home/chd/log/dtmp
}

procing() {
  trap 'tput ed;tput rc;exit 0;' 6
  tput ed
  while [ 1 ]
  do
    for j in '-' '\\' '|' '/'
    do
      tput sc
      ptoday=`date  +%Y%m%d`
      pctime=`date  +%H:%M:%S`
      echo -ne  "$ptoday $pctime : $1...   $j"
      sleep 0.2
      tput rc
    done
  done
}

cyear=`date  +%Y`
today=`date  +%Y%m%d`
today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
syssep="/"

if [ $# -ne 8 ];then
  echo "Usage: ./data-sum.sh datadir startyear startmonthday endyear endmonthday datatype(TIO or HA) report(1-report/0-no report) mail(1 mail/0-no mail)"
  echo "Example: ./data-sum-xx.sh  /lustre/data 2020 0928  2020 1001 TIO 1 1"
  echo "         ./data-sum-xx.sh  /lustre/data 2020 0928  2020 1001 HA 0 0"
  exit 1
fi

datapre=$1
syear=$2
smonthday=$3
eyear=$4
emonthday=$5
datatype=$6
report=$7
mail=$8

pver=0.1.4
num=0
size=0.0
obstime=0.0
obsday=0

snum=0
ssize=0.0
sobstime=0.0

site=fso
device=lustre
homepre=/home/chd/data-info
suminfo=$homepre/$syear$smonthday-$eyear$emonthday-$datatype@fso.sum

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
echo " "
echo " "
echo "                      $datatype Data Summary $syear$smonthday to $eyear$emonthday @fso                                  "
echo "                                          Version: $pver                                                                     "
echo "                                         $today $ctime                  "
echo "                      $datatype Data Summary $syear$smonthday to $eyear$emonthday @fso                                  ">$suminfo
echo "                                          Version: $pver                                                                     ">>$suminfo
echo "                                         $today $ctime                  ">>$suminfo
echo "**********************************************************************************************************************************************************************************"
echo "**********************************************************************************************************************************************************************************">>$suminfo
echo "Date       Nums.                 Size(GiB)                  StartTime                                           EndTime                                     Obs. Time(hrs)" >>$suminfo
echo "**********************************************************************************************************************************************************************************">> $suminfo
while [ $i -le $checkdays ]
do
  checkdate=`date +%Y%m%d -d "+$i days $sdate"`
  checkyear=${checkdate:0:4}
  checkmonthday=${checkdate:4:4}
	today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S` 
	echo "$today0 $ctime : Start $checkdate $datatype  Data Summerizing @fso"
  /home/chd/data-sum-daily.sh $datapre $checkyear $checkmonthday $datatype 0 &
  waiting "$!" "$datatype Date Summerizing on $checkdate @$device" "Summerizing $datatype Data on $checkdate @$device"
  today0=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S` 
  tput ed
  tput rc
  echo "$today0 $ctime : Task of $datatype Date Summerizing on $checkdate @$site Has been Done..."
  if [ -f "$homepre/$checkyear/$datatype-$checkyear-$checkmonthday.sum" ];then 
    if [ $report -eq "1" ];then 
      cat $homepre/$checkyear/$datatype-$checkyear-$checkmonthday.sum >>  $suminfo
    fi
    snum=`cat $homepre/$checkyear/$datatype-$checkyear-$checkmonthday.sum|awk '{print $2}'`
    ssize=`cat $homepre/$checkyear/$datatype-$checkyear-$checkmonthday.sum|awk '{print $3}'`
    sobstime=`cat $homepre/$checkyear/$datatype-$checkyear-$checkmonthday.sum|awk '{print $8}'`
  else
    echo "$checkdate   00000000              0000000.0000               0000-00-00 00:00:00.000000000                       0000-00-00 00:00:00.000000000               0000.000000" >>$suminfo
    snum=0
    ssize=0.0
    sobstime=0.0
    j=0
    k=0
  fi
  num=`echo $num $snum|awk '{print($1+$2)}'`
  size=`echo $szie $ssize|awk '{print($1+$2)}'`
  if [ $sobstime > 0.5 ] || [ $snum > 1000 ];then 
    obstime=`echo $obstime $sobstime|awk '{print($1+$2)}'`
    obsday=`echo $obsday|awk '{print($1+1)}'`
  fi
  let i++
  echo "                  : $i day(s) Processed..."
done
num=`printf "%08d" $num`
size=`printf "%012.4f" $size`
obstime=`printf "%011.6f" $obstime`
obsday=`printf "%04d" $obsday`
checkdays=`echo $checkdays|awk '{ print($1+1)}'`
checkdays=`printf "%04d" $checkdays`
echo "******************************************************************************************************************************************************************************">> $suminfo
echo "Start         End           Nums.               Size(GiB)               Total Obs. Time(hrs)     Total Obs. Day(s)    Total Cal. Day(s)" >>$suminfo
echo "$syear$smonthday      $eyear$emonthday      $num            $size            $obstime              $obsday                 $checkdays" >>$suminfo

today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
if [ $mail -eq "1" ];then 
  echo "$today0 $ctime : Send Summary  for $year$monthday $datatype @$device to Users..."
  mail -s "Summary of $datatype Data from $syear$smonthday to $eyear$emonthday @fso" nvst_obs@ynao.ac.cn < $suminfo
  mail -s "Summary of $datatype Data from $syear$smonthday to $eyear$emonthday @fso" chd@ynao.ac.cn < $suminfo
fi
today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
t1=`date +%s`
dt=`echo $t0 $t1|awk '{print($2-$1)}'`
echo "$today0 $ctime : $i days $datatype Data  Summerized..."
echo "             From : $sdate"
echo "               To : $edate"
echo "             Used : $dt secs."
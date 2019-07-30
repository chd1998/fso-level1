#!/bin/sh
#author: chen dong @fso
#purposes: check the data & copy the wrong file(s) again
#Usage: ./fso-data-check-copy-cron.sh ip port  destdir user password datatype(TIO or HA) threadnumber
#Example: ./fso-data-check-copy-cron.sh  192.168.111.120 21 /lustre/data tio ynao246135 TIO fits 11062080
#Example: ./fso-data-check-copy-cron.sh  192.168.111.122 21 /lustre/data ha ynao246135 HA fits 2111040
#changlog: 
#       20190725   Release 0.1     first working version.sh
#      
# 

#waiting pid taskname prompt
waiting() {
  local pid="$1"
  taskname="$2"
  procing "$3" &
  local tmppid="$!"
  wait $pid

  wctime=`date --date='0 days ago' +%H:%M:%S`
	wtoday=`date --date='0 days ago' +%Y%m%d`
               
  echo "$wtoday $wctime: $2 Task Has Done!"
  dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  echo "                   Finishing...."
  kill -6 $tmppid >/dev/null 1>&2
  echo "$dt1" > /home/chd/log/$(basename $0)-$datatype-sdtmp.dat
}

procing() {
  trap 'exit 0;' 6
  tput ed
  while [ 1 ]
  do
    sleep 1
    ptoday=`date --date='0 days ago' +%Y%m%d`
    pctime=`date --date='0 days ago' +%H:%M:%S`
    echo "$ptoday $pctime: $1, Please Wait...   "
  done
}


cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"

if [ $# -ne 8 ];then
  echo "Usage: ./fso-data-check-copy-cron.sh ip port  destdir user password datatype(TIO or HA) fileformat stdsize"
  echo "Example: ./fso-data-check-copy-cron.sh  192.168.111.120 21 /lustre/data tio ynao246135 TIO fits 11062080"
  echo "Example: ./fso-data-check-copy-cron.sh  192.168.111.122 21 /lustre/data ha ynao246135 HA fits 2111040"
  exit 1
fi
server1=$1
port=$2
destpre=$3
user=$4
password=$5
datatype=$6
fileformat=$7
stdsize=$8

#errlist=/home/chd/log/$datatype-$today-remote.list
errlist=/home/chd/log/$datatype-$fileformat@$(date +\%Y\%m\%d)-error-total.list

lockfile=/home/chd/log/$(basename $0)-$datatype.lock

if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    echo "$today $ctime: $(basename $0) is running for syncing $datatype data..." 
    exit 1
  else
    echo $$>$lockfile
  fi
else
  echo $$>$lockfile
fi

ctime1=`date --date='0 days ago' +%H:%M:%S`
st1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
echo "                                                       "
echo "======= Welcome to Data Archiving System @ FSO! ======="
echo "              fso-data-check-copy.sh                   "
echo "          (Release 0.1 20190725 11:51)                 "
echo "                                                       "
echo "           Check $datatype data and copy               "
echo "                                                       "
echo "                $today $ctime1                          "
echo "======================================================="
echo " "
echo "$today $ctime: $datatype Checking, please wait..."
/home/chd/fso-data-check-cron.sh /lustre/data/$(date +\%Y)/$(date +\%Y\%m\%d)/$datatype $datatype $fileformat $stdsize > /home/chd/log/check-$datatype-size@$today.log &
waiting "$!" "$datatype Checking" "Checking $datatype Data"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: $datatype Check Failed!"
  cd /home/chd/
  exit 1
fi
errsize1=`cat $errlist|wc -l`
if [ $errsize1 -eq 0 ]; then
errsize1=0
fi


echo "$today $ctime: $datatype Copying, please wait..."
/home/chd/fso-copy-wget-error-cron-v02.sh $server $port $user $password $errlist > /home/chd/log/$datatype-error-copy-$(date +\%Y\%m\%d).log &
waiting "$!" "$datatype Copying" "Copying $datatype Data"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: $datatype Copy Failed!"
  cd /home/chd/
  exit 1
fi

errsize2=`cat $errlist|wc -l`
ctime3=`date --date='0 days ago' +%H:%M:%S`
#sending email to observers
if [ $errsize2 -eq 0 ]; then
  echo "$today $ctime3: $datatype data are O.K.!" | mail -s "$today $ctime3: $datatype Data Sync Result @ lustre" nvst_obs@ynao.ac.cn
  echo "$today $ctime3: $datatype data are O.K.!" | mail -s "$today $ctime3: $datatype Data Sync Result @ lustre" chd@ynao.ac.cn
else
  mail -s "$today $ctime3: $datatype Data Sync Result @ lustre" nvst_obs@ynao.ac.cn < $errlist
  mail -s "$today $ctime3: $datatype Data Sync Result @ lustre" chd@ynao.ac.cn < $errlist
fi

ctime4=`date --date='0 days ago' +%H:%M:%S`
st2=`echo $ctime4|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
stdiff=`echo "$st1 $st2"|awk '{print($2-$1)}'`

echo "$today $ctime4: Checking & Copying $datatype data @ FSO finished!"
echo "           Total : $errsize1 error file(s) Copied!"
echo "       Time Used : $stdiff secs."
echo " Total Time From : $ctime1"
echo "              To : $ctime4"
echo "================================================================================="
rm -rf $lockfile





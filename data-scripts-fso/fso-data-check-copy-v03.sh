#!/bin/sh
#author: chen dong @fso
#purposes: check the data & copy the wrong file(s) again
#Usage: ./fso-data-check-copy-v03.sh ip port   destdir user password year monthday fileformat stdsize
#Example: ./fso-data-check-copy-v03.sh  192.168.111.120 21 /lustre/data tio ynao246135 2019 0915 fits 11062080
#Example: ./fso-data-check-copy-v03.sh  192.168.111.122 21 /lustre/data ha ynao246135 2019 0915 fits 2111040
#changlog: 
#       20190725   Release 0.1     first working version.sh
#                  Release 0.2     fixed some minor errors and revised display info
#       20190914   Release 0.3     Add comparison of remote & local file(s), and parameters changed
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
  
  echo $'\n'             
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
    for j in '-' '\\' '|' '/'
    do
      tput sc
      ptoday=`date --date='0 days ago' +%Y%m%d`
      pctime=`date --date='0 days ago' +%H:%M:%S`
      echo -ne  "$ptoday $pctime: $1...   $j"
      sleep 1
      tput rc
    done
  done
}

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
mday=`date --date='0 days ago' +%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"

if [ $# -ne 9 ];then
  echo "Usage: ./fso-data-check-copy-v03.sh ip port  destdir user password year monthday fileformat stdsize"
  echo "Example: ./fso-data-check-copy-v03.sh   192.168.111.120 21 /lustre/data tio ynao246135 2019 0915 fits 11062080"
  echo "Example: ./fso-data-check-copy-v03.sh  192.168.111.122 21 /lustre/data ha ynao246135 2019 0915 fits 2111040"
  exit 1
fi
server=$1
port=$2
destpre=$3
user=$4
password=$
year=$6
monthday=$7
fileformat=$8
stdsize=$9

datatype=`echo $user|tr -t 'a-z' 'A-Z'`

#errlist=/home/chd/log/$datatype-$today-remote.list
# remote & local diff list
remoteerrlist=/home/chd/log/$datatype-$fileformat-$year$monthday-diff.list
# local wrongsize list
errlist=/home/chd/log/$datatype-localwrongsize-$year$monthday.list
targetdir=/lustre/data/$year/$monthday
tmplist=/home/chd/log/$datatype-$fileformat-$year$monthday-tmp.list

touch $remoteerrlist
touch $errlist
touch $tmplist

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
echo "          (Release 0.3 20190914 07:14)                 "
echo "                                                       "
echo "           Check $datatype data and copy               "
echo "                                                       "
echo "                $today $ctime1                         "
echo "======================================================="
echo " "

ctime1=`date --date='0 days ago' +%H:%M:%S`
touch ./log/pingtmp
echo "$today $ctime1: Testing $server is online or not, please wait..."
ping $server -c5 | grep ttl >> ./log/pingtmp
pingres=`cat ./log/pingtmp | wc -l`
rm -f ./log/pingtmp
ctime1=`date --date='0 days ago' +%H:%M:%S`
if [ $pingres -ne 0 ];then 
  #comparing remote and local file(s),creat local missing file(s)
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime1: $server is online..."
  echo "$today $ctime1: Remote & Local $datatype File(s) Checking, please wait..."
  #/home/chd/fso-data-check-remote-cron.sh 192.168.111.120 21 tio ynao246135 2019 0913 TIO fits
  /home/chd/fso-data-check-remote-cron.sh $server $port $user $password $year $monthday $datatype $fileformat > /home/chd/log/check-remote-$datatype-size@$year$monthday.log &
  waiting "$!" "Remote & Local $datatype File(s) Checking" "Checking Remote & Local $datatype File(s)"
  if [ $? -ne 0 ];then
    ctime3=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime3: $datatype Check Failed!"
    cd /home/chd/
    exit 1
  fi
  if [ -f $remoteerrlist ]; then 
    remoteerrsize=`cat $remoteerrlist|wc -l`
    if [ $remoteerrsize -eq 0 ]; then
      remoteerrsize=0
    fi
  else
    remoteerrsize=0
  fi

  #copying local missing file(s) from remote server
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: Copying local missing $datatype file(s) from remote, please wait..."
  /home/chd/fso-copy-wget-error-cron-v02.sh $server $port $user $password $remoteerrlist > /home/chd/log/remote-$datatype-error-copy-$year$monthday.log &
  waiting "$!" "Local $datatype Missing File(s) Copying" "Copying Local Missing $datatype Data from Remote"
  if [ $? -ne 0 ];then
    ctime3=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime3: $datatype Copy Failed!"
    cd /home/chd/
    exit 1
  fi
  if [ -f $remoteerrlist ]; then
    remoteerrsize1=`cat $remoteerrlist|wc -l`
    if [ $remoteerrsize1 -eq 0 ]; then
      remoteerrsize1=0
    fi
  else
    remoteerrsize1=0
  fi
else
  echo "$today $ctime1: $server is offline, skip checking remote & local file(s)..."
  touch $remoteerrlist
  remoteerrsize=0
  remoteerrsize1=0
fi
rm -f ./log/pingtmp


#checking local wrong size file(s)
ctime=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime: Local Wrong Size $datatype File(s) Checking, please wait..."
/home/chd/fso-data-check-local-cron.sh $targetdir $datatype $fileformat $stdsize > /home/chd/log/check-local-$datatype-size-$year$monthday.log &
waiting "$!" "Local Wrong Size $datatype File(s) Checking" "Checking Local Wrong Size $datatype File(s)"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: $datatype Check Failed!"
  cd /home/chd/
  exit 1
fi
if [ -f $errlist ]; then
  errsize1=`cat $errlist|wc -l`
  if [ $errsize1 -eq 0 ]; then
    errsize1=0
  fi
else
  errsize1=0
fi

if [ $pingres -ne 0 ];then
  #correcting local wrong size file(s)...
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: Wrong size $datatype File(s) Copying from remote, please wait..."
  /home/chd/fso-copy-wget-error-cron-v02.sh $server $port $user $password $errlist > /home/chd/log/local-$datatype-error-copy-$year$monthday.log &
  waiting "$!" "Local Wrong Size $datatype File(s) Copying" "Copying Local Wrong Size $datatype File(s) from Remote"
  if [ $? -ne 0 ];then
    ctime3=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime3: $datatype Copy Failed!"
    cd /home/chd/
    exit 1
  fi
else
  echo "$today $ctime: Skiping Local Wrong Size $datatype Data File(s) Copying..."
fi
if [ -f $errlist ]; then
  errsize2=`cat $errlist|wc -l`
  if [ $errsize2 -eq 0 ]; then
    errsize2=0
  fi
else
  errsize2=0
fi


#errsize2=`cat $errlist|wc -l`
#add local missing files' no. and local wrong size's no. 
errsize3=`echo "$remoteerrsize $errsize1"|awk '{print($2+$1)}'`
errsize4=`echo "$remoteerrsize1 $errsize2"|awk '{print($2+$1)}'`

ctime3=`date --date='0 days ago' +%H:%M:%S`
cat $remoteerrlist $errlist > $tmplist
#echo "$today $ctime3: Local Missing File(s):" > $tmplist
#cat $remoteerrlist >> $tmplist
#echo "                " >> $tmplist
#echo "$today $ctime3: Local Wrong Size File(s):" >> $tmplist
#cat $errlist >> $tmplist

errsize5=`cat $tmplist|wc -l`

ctime3=`date --date='0 days ago' +%H:%M:%S`
#sending email to observers
echo " "
echo "$today $ctime3: Sending Email to Observation Assistants..."
if [ $errsize4 -eq 0 ]; then
  echo "$today $ctime3: $datatype data under /lustre/data/$(date +\%Y)/$(date +\%Y\%m\%d)/$datatype are O.K.!" | mail -s "lustre-$datatype@$today: $errsize4 Error File(s) Found" nvst_obs@ynao.ac.cn
  echo "$today $ctime3: $datatype data under /lustre/data/$(date +\%Y)/$(date +\%Y\%m\%d)/$datatype are O.K.!" | mail -s "lustre-$datatype@$today: $errsize4 Error File(s) Found" chd@ynao.ac.cn
else
  mail -s "lustre-$datatype@$today: $errsize4 Error File(s) Found" nvst_obs@ynao.ac.cn < $tmplist
  mail -s "lustre-$datatype@$today: $errsize4 Error File(s) Found" chd@ynao.ac.cn < $tmplist
fi

ctime4=`date --date='0 days ago' +%H:%M:%S`
st2=`echo $ctime4|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
stdiff=`echo "$st1 $st2"|awk '{print($2-$1)}'`

echo "$today $ctime4: Checking & Copying $datatype data @ FSO finished!"
echo "          Before : $errsize3 error file(s) Found!"
echo "           After : $errsize4 error file(s) left!"
echo "                 : see $tmplist for details"
echo "       Time Used : $stdiff secs."
echo " Total Time From : $ctime1"
echo "              To : $ctime4"
echo "================================================================================="
rm -rf $lockfile

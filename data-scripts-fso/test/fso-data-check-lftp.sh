#!/bin/bash
#author: chen dong @fso
#purposes: periodically getting data info from remote site via lftp
#usage:  run in crontab every 30 min.  from 08:00-20:00
#example: none
#changlog: 
#       20190718    Release 0.1     first working version
# 
#waiting pid taskname prompt
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
               
  echo "$wtoday $wctime: $2 Task Has Done!"
  dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  echo "                   Finishing...."
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
    echo "$ptoday $pctime: $1, Please Wait...   "
  done
}

#procName="lftp"
cyear=`date  +%Y`
today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
syssep="/"

if [ $# -ne 5 ];then
  echo "Usage: ./fso-data-check-lftp.sh ip port  user password datatype(TIO or HA)"
  echo "Example: ./fso-data-check-lftp.sh  192.168.111.120 21  tio ynao246135 TIO"
  exit 1
fi
server1=$1
port=$2
#destpre0=$3
user=$3
password=$4
datatype=$5

server=${server1}:${port}

#umask 0000

filenumber=/home/chd/log/$datatype-$today-$server1-filenumber.dat
filesize=/home/chd/log/$datatype-$today-$server1-filesize.dat

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

st1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
echo "                                                       "
echo "======= Welcome to Data Archiving System @ FSO! ======="
echo "                fso-count-lftp.sh                      "
echo "          (Release 0.1 20190718 16:55)                 "
echo "                                                       "
echo "     Counting $datatype data @ $server1                "
echo "                                                       "
echo "                $today $ctime                          "
echo "======================================================="
echo " "
srcdir=${syssep}${today}${syssep}${datatype}
srcdir1=${srcpre0}

ctime=`date  +%H:%M:%S`
echo "$today $ctime: Starting to Count $datatype data @ $server1, Please wait..."
ctime1=`date  +%H:%M:%S`
mytime1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
server=ftp://$user:$password@$server

lftp  $server -e "find $cdir/ -type f -name '*.fits' -printf "%h/%f %s\n"" >/home/chd/log/filename-size-$datatype@$server1.dat &
waiting "$!" "$datatype Name & Size Counting @ $server1" "Counting $datatype Data Name & Size @ $server1"
if [ $? -ne 0 ];then
  ctime2=`date  +%H:%M:%S`
  echo "$today $ctime3: Counting $datatype Data @ $server1 Failed!"
  cd /home/chd/
  exit 1
fi
ctime2=`date  +%H:%M:%S`
mytime1=`echo $ctime2|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
rm -rf $lockfile
cd /home/chd/
exit 0


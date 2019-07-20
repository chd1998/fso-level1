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
  wctime=`date --date='0 days ago' +%H:%M:%S`
	wtoday=`date --date='0 days ago' +%Y%m%d`
               
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
    ptoday=`date --date='0 days ago' +%Y%m%d`
    pctime=`date --date='0 days ago' +%H:%M:%S`
    echo "$ptoday $pctime: $1, Please Wait...   "
  done
}

#procName="lftp"
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"

if [ $# -ne 5 ];then
  echo "Usage: ./fso-count-lftp.sh ip port  user password datatype(TIO or HA)"
  echo "Example: ./fso-count-lftp.sh  192.168.111.120 21  tio ynao246135 TIO"
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

ctime=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime: Starting to Count $datatype data @ $server1, Please wait..."
ctime1=`date --date='0 days ago' +%H:%M:%S`
mytime1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
server=ftp://$user:$password@$server
lftp  $server -e "du -sm $srcdir; quit" | awk '{print $1}'>/home/chd/log/tmp-size-$datatype.dat &
waiting "$!" "$datatype Size Counting @ $server1" "Counting $datatype Data Size @ $server1"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: Syncing $datatype Data @ FSO Failed!"
  cd /home/chd/
  exit 1
fi
filetmp=${srcdir}${syssep}*.fits
lftp  $server -e "find $srcdir |grep fits| wc -l ; quit" > /home/chd/log/tmp-number-$datatype.dat &
waiting "$!" "$datatype Number Counting @ $server1" "Counting $datatype Data Number @ $server1"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: Syncing $datatype Data @ FSO Failed!"
  cd /home/chd/
  exit 1
fi
ctime2=`date --date='0 days ago' +%H:%M:%S`

mytime2=$(cat /home/chd/log/$(basename $0)-$datatype-sdtmp.dat)
size=$(cat /home/chd/log/tmp-size-$datatype.dat)
number=$(cat /home/chd/log/tmp-number-$datatype.dat)
echo "$today $ctime2 $size" > $filesize
echo "$today $ctime2 $number"> $filenumber
n2=$(cat $filenumber|awk '{print $3}')
s2=$(cat $filesize|awk '{print $3}')

timediff=`echo "$mytime1 $mytime2"|awk '{print($2-$1)}'`
if [ $timediff -le 0 ]; then
	timediff=1
fi

ctime4=`date --date='0 days ago' +%H:%M:%S`

echo "$today $ctime4: Succeeded in Counting $datatype data size & number @ $server1!"
echo "          Server : $server1"
echo "       Directory : $srcdir"
echo "      Total File : $n2 file(s)"
echo "      Total Size : $s2 MB"
echo " Total Time Used : $timediff secs."
echo " Total Time From : $ctime1"
echo "              To : $ctime4"
echo "=========================================================================="
rm -rf $lockfile
cd /home/chd/
exit 0


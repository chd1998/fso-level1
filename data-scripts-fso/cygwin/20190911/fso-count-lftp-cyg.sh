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
dirpre="/cygdrive"
logpath="/cygdrive/d/chd/LFTP4WIN-master/home/chd/log"
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

fileinfo=$logpath/$datatype-$today-$server1-fileinfo.dat
#filesize=$logpath/$datatype-$today-$server1-filesize.dat

lockfile=$logpath/$(basename $0)-$datatype.lock


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
echo "$today $ctime: Starting to Count $datatype data @ $1, Please wait..."
ctime1=`date  +%H:%M:%S`
mytime1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
server=ftp://$user:$password@$server
lftp  $server -e "du -sm $srcdir; quit" | awk '{print $1}'>$logpath/tmp-size-$datatype.dat & 
waiting "$!" "$datatype size Counting @ $1" "Counting $datatype Data size @ $1"
if [ $? -ne 0 ];then
  ctime3=`date  +%H:%M:%S`
  echo "$today $ctime3: Counting $datatype Data file size @ $1 Failed!"
#  cd /home/chd/
  exit 1
fi
lftp  $server -e "find $srcdir | wc -l ; quit" > $logpath/tmp-number-$datatype.dat &
waiting "$!" "$datatype Number Counting @ $1" "Counting $datatype Data Number @ $1"
if [ $? -ne 0 ];then
  ctime3=`date  +%H:%M:%S`
  echo "$today $ctime3: Counting $datatype Data file number @ $1 Failed!"
#  cd /home/chd/
  exit 1
fi
ctime2=`date  +%H:%M:%S`

mytime2=`echo $ctime2|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
size=$(cat $logpath/tmp-size-$datatype.dat)
number=$(cat $logpath/tmp-number-$datatype.dat)
echo "$today $ctime1 $number $size" > $fileinfo
#echo "$today $ctime2 $number"> $filenumber
cday=$(cat $fileinfo|awk '{print $1}')
ct=$(cat $fileinfo|awk '{print $2}')
n2=$(cat $fileinfo|awk '{print $3}')
s2=$(cat $fileinfo|awk '{print $4}')


timediff=`echo "$mytime1 $mytime2"|awk '{print($2-$1)}'`
if [ $timediff -le 0 ]; then
	timediff=1
fi

ctime4=`date  +%H:%M:%S`

echo "$today $ctime4: Succeeded in Counting $datatype data size & number @ $server1!"
echo "             For : $server1 "
echo "               @ : $cday $ct"
echo "       Directory : $srcdir"
echo "      Total File : $n2 file(s)"
echo "      Total Size : $s2 MB"
echo " Total Time Used : $timediff secs."
echo " Total Time From : $ctime1"
echo "              To : $ctime2"
echo "=========================================================================="
rm -rf $lockfile
#cd /home/chd/
exit 0


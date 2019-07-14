#!/bin/bash
#author: chen dong @fso
#purposes: periodically syncing data from remoteip to local lustre storage via lftp
#usage:  run in crontab every 1 min.  from 08:00-20:00
#example: none
#changlog: 
#       20190603    Release 0.1     first version for tio-sync.sh
#       20190625    Release 0.2     revised lftp performance & multi-thread
#       20190703    Release 0.3     fix some errors 
#       20190705    Release 0.4     timing logic revised

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

if [ $# -ne 6 ];then
  echo "Usage: ./fso-sync-lftp.sh ip port  destdir user password datatype(TIO or HA)"
  echo "Example: ./fso-sync-lftp.sh  192.168.111.120 21 /lustre/data tio ynao246135 TIO"
  exit 1
fi
server=$1
port=$2
destpre0=$3
user=$4
password=$5
datatype=$6

server=${server}:${port}

#umask 0000

filenumber=/home/chd/log/$(basename $0)-$datatype-number.dat
filesize=/home/chd/log/$(basename $0)-$datatype-size.dat
filenumber1=/home/chd/log/$(basename $0)-$datatype-number-1.dat
filesize1=/home/chd/log/$(basename $0)-$datatype-size-1.dat

lockfile=/home/chd/log/$(basename $0)-$datatype.lock

if [ ! -f $filenumber ];then
  echo "0">$filenumber
fi
if [ ! -f $filesize ];then 
  echo "0">$filesize
fi
if [ ! -f $filenumber1 ];then
  echo "0">$filenumber1
fi
if [ ! -f $filesize1 ];then
  echo "0">$filesize1
fi

if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    echo "$today $ctime: $(basename $0) is running" 
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
echo "                fso-sync-lftp.sh                       "
echo "          (Release 0.4 20190703 21:14)                 "
echo "                                                       "
echo "         sync $datatype data to $destpre0              "
echo "                                                       "
echo "                $today $ctime                          "
echo "======================================================="
echo " "
#procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
#pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
#if [ $procCmd -le 0 ];then
destdir=${destpre0}${syssep}${cyear}${syssep}${today}${syssep}
targetdir=${destdir}${datatype}
if [ ! -d "$targetdir" ]; then
  mkdir -m 777 -p $targetdir
else
  echo "$today $ctime: $targetdir exists!"
fi
srcdir=${syssep}${today}${syssep}${datatype}
srcdir1=${srcpre0}

n1=$(cat $filenumber)
s1=$(cat $filesize)

ctime=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime: Syncing $datatype data @ FSO..."
echo "             From: $server$srcdir "
echo "             To  : $targetdir "
echo "$today $ctime: Sync Task Started, Please Wait ... "
#cd $destdir
ctime1=`date --date='0 days ago' +%H:%M:%S`
mytime1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
server=ftp://$user:$password@$server
lftp  $server -e "mirror --only-missing --continue  --parallel=40  $srcdir $targetdir; quit">/dev/null 2>&1 &
#lftp -p 2121 -u tio,ynao246135 -e "mirror --only-missing --continue  --parallel=40  /20190704/TIO /lustre/data/2019/20190704/TIO; quit" ftp://192.168.111.120 >/dev/null 2>&1 &
#wget  --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=tio --ftp-password=ynao246135 --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob --preserve-permissions $srcdir1

waiting "$!" "$datatype Syncing" "Syncing $datatype Data"
ctime3=`date --date='0 days ago' +%H:%M:%S`
if [ $? -ne 0 ];then
  echo "$today $ctime3: Syncing $datatype Data @ FSO Failed!"
  cd /home/chd/
  exit 1
fi
ctime2=`date --date='0 days ago' +%H:%M:%S`

mytime2=$(cat /home/chd/log/$(basename $0)-$datatype-sdtmp.dat)
#mytime2=`echo $ttmp|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`

chmod 777 -R $targetdir &
waiting "$!" "Permission Changing" "Changing Permission"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: Changing Permission of $datatype Failed!"
  cd /home/chd/
  exit 1
fi
ctime2=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime2: Summerizing File Numbers & Size..."

#n2=`ls -lR $targetdir | grep "^-" | wc -l` 
#s2=`du -sm $targetdir|awk '{print $1}'` 

ls -lR $targetdir | grep "^-" | wc -l > $filenumber1 &
waiting "$!" "File Number Sumerizing" "Sumerizing File Number"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Number of $datatype Failed!"
  cd /home/chd/
  exit 1
fi

du -sm $targetdir|awk '{print $1}' > $filesize1 &
waiting "$!" "File Size Summerizing" "Sumerizing File Size"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Size of $datatype Failed!"
  cd /home/chd/
  exit 1
fi
if [ ! -d "$targetdir" ]; then
  echo "0" > $filesize1
fi

n2=$(cat $filenumber1)
s2=$(cat $filesize1)

sn=`echo "$n1 $n2"|awk '{print($2-$1)}'`
ss=`echo "$s1 $s2"|awk '{print($2-$1)}'`

timediff=`echo "$mytime1 $mytime2"|awk '{print($2-$1)}'`
if [ $timediff -le 0 ]; then
	timediff=1
fi
speed=`echo "$ss $timediff"|awk '{print($1/$2)}'`

echo $n2>$filenumber
echo $s2>$filesize

ctime4=`date --date='0 days ago' +%H:%M:%S`
st2=`echo $ctime4|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
stdiff=`echo "$st1 $st2"|awk '{print($2-$1)}'`

echo "$today $ctime4: Succeeded in Syncing $datatype data @ FSO!"
echo "          Synced : $sn file(s)"
echo "          Synced : $ss MB "
echo "  Sync Time Used : $timediff secs."
echo "        @  Speed : $speed MB/s"
echo "      Total File : $n2 file(s)"
echo "      Total Size : $s2 MB"
echo " Total Time Used : $stdiff secs."
echo " Total Time From : $ctime1"
echo "              To : $ctime4"
echo "======================================================="
rm -rf $lockfile
cd /home/chd/
exit 0
#else
#  echo "$today $ctime: $procName  is running..."
#  echo "              PID: $pid                    "
#  exit 0
#fi


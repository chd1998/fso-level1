#!/bin/bash
#author: chen dong @fso
#Copy specified date TIO/HA data on remote host to /lustre/data mannually
#Usage: ./fso-copy-lftp-v14.sh srcip port  dest year(4 digits) monthday(4 digits) user password datatype(TIO/HA) threadnumber
#Example: ./fso-copy-lftp-v14.sh 192.168.111.120 21 /lustre/data 2019 0427 tio ynao246135 TIO 10
#Example: ./fso-copy-lftp-v14.sh 192.168.111.122 21 /lustre/data 2019 0427 ha ynao246135 HA 10
#changlog: 
#        20190420       Release 0.1.0   first prototype release 0.1
#        20190421       Release 0.2.0   fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
#        20190423       Release 0.3.0   fix errors
#        20190426       Release 0.4.0   fix errors
#        20190428       Release 0.5.0   add monthday to the src dir
#                       Release 0.6.0   datatype is an option now
#        20190603       Release 0.7.0   using lftp instead of wget
#        20190604       Release 0.8.0   add progress bar to lftp
#        20190608       Release 0.9.0   fixed error in directory
#                       Release 1.0.0   improve display info
#        20190702       Release 1.1.0   revise some logical relations
#        20190704       Release 1.2.0   using lftp & add input args
#        20190705       Release 1.3.0   logics revised
#                       Release 1.4.0   revise timing logics
#        20191015       Release 1.4.1   revise time calculation
#        20200615       Release 1.4.2   fixed some minor errors
#                                       add ping test
#
#waiting pid taskname prompt
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
  echo "$wtoday $wctime: $2 Task Has Done!"
#  dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  dt1=`date +%s`
#  echo "                   Finishing..."
  kill -6 $tmppid >/dev/null 1>&2
  echo "$dt1" > /home/chd/log/dtmp
}

procing() {
  trap 'exit 0;' 6
  tput ed
  while [ 1 ]
  do
    for j in '-' '\\' '|' '/'
    do
      tput sc
      ptoday=`date  +%Y%m%d`
      pctime=`date  +%H:%M:%S`
      echo -ne  "$ptoday $pctime: $1...   $j"
      sleep 0.2
      tput rc
    done
  done
}

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    exit 1
}

cyear=`date  +%Y`
today=`date  +%Y%m%d`
today0=`date  +%Y-%m-%d`
ctime=`date  +%H:%M:%S`
ctime0=`date  +%H:%M:%S`
if [ $# -ne 9 ]  ;then
  echo "Copy specified date TIO/HA data on remote host to /lustre/data mannually"
  echo "Usage: ./fso-copy-lftp-v14.sh srcip port  dest year(4 digits) monthday(4 digits) user password datatype(TIO/HA) threadnumber"
  echo "Example: ./fso-copy-lftp-v14.sh 192.168.111.120 21 /lustre/data 2019 0427 tio ynao246135 TIO 10"
  echo "Example: ./fso-copy-lftp-v14.sh 192.168.111.122 21 /lustre/data 2019 0427 ha ynao246135 HA 10"
  exit 1
fi

#procName="lftp"

syssep="/"
ftpserver=$1
remoteport=$2
destpre0=$3
srcyear=$4
srcmonthday=$5
ftpuser=$6
password=$7
datatype=$8
threadn=$9
#ftpuser=$(echo $datatype|tr '[A-Z]' '[a-z]')

server=$1
ftpserver=ftp://$ftpuser:$password@$ftpserver:$remoteport
#echo "$ftpserver"
#read

logpre=/home/chd/log

lockfile=/home/chd/log/$(basename $0)-$srcyear$srcmonthday.lock
if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    echo "$todday $ctime: $(basename $0) is running" && exit 1
  else
    echo $$>$lockfile
  fi
else
  echo $$>$lockfile
fi

progver=1.4.2
starttime=`date +%s`

echo " "
echo "============ Welcome to FSO Data System@FSO! ============"
echo "                                                         "
echo "                 $(basename $0)                          "  
echo "                                                         "
echo "            Relase $progver     20200615 09:04           "
echo "                                                         "
echo "                $today    $ctime                         "
echo "                                                         "
echo "========================================================="
echo " "
#procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
#pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
#if [ $procCmd -le 0 ];then
destdir=${destpre0}${syssep}${srcyear}${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
#remotesrcdir=${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
srcdir=${ftpserver1}${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
srcdir1=${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}

if [ ! -d "$destdir" ]; then
  mkdir -p -m 777 $destdir
else
  echo "$destdir already exist!"
fi

ctime=`date  +%H:%M:%S`
echo "$today $ctime: Syncing $datatype data @ FSO..."
echo "                   From: $srcdir "
echo "                   To  : $destdir "
echo "                   Please Wait..."

fn1=`ls -lR $destdir | grep "^-" | wc -l`
fs1=`du -sm $destdir | awk '{print $1}'`
ctime=`date  +%H:%M:%S`
t1=`date +%s`
lftp $ftpserver -e "mirror --parallel=$threadn $srcdir1  $destdir; quit" >/dev/null 2>&1 &
waiting "$!" "$datatype Syncing" "Syncing $datatype Data"
if [ $? -ne 0 ];then
  ctime1=`date  +%H:%M:%S`
  echo "$today $ctime1: Failed in Syncing $datatype Data from $srcdir to $destdir"
  cd /home/chd
  exit 1
fi
t2=`date +%s`
ttmp=$(cat /home/chd/log/dtmp)

ctime1=`date  +%H:%M:%S`
#t1=`date +%s`
#t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`

targetdir=${destdir}
ls -lR $targetdir | grep "^-" | wc -l > /home/chd/log/tmpfn2.dat &
waiting "$!" "File Number Sumerizing" "Sumerizing File Number"
if [ $? -ne 0 ];then
  ctime3=`date  +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Number of $datatype Failed!"
  cd /home/chd/
  exit 1
fi

#fn1=$(cat /home/chd/log/tmpfn1.dat)
fn2=$(cat /home/chd/log/tmpfn2.dat)


du -sm $targetdir|awk '{print $1}' > /home/chd/log/tmpfs2.dat &
waiting "$!" "File Size Summerizing" "Sumerizing File Size"
if [ $? -ne 0 ];then
  ctime3=`date  +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Size of $datatype Failed!"
  cd /home/chd/
  exit 1
fi
if [ ! -d "$targetdir" ]; then
  echo "0" > /home/chd/log/tmpfs.dat
fi  

#fs1=$(cat /home/chd/log/tmpfs1.dat)
fs2=$(cat /home/chd/log/tmpfs2.dat)

#chmod 777 -R $destdir &
find $targetdir ! -perm 777 -type f -exec chmod 777 {} \; &
find $targetdir ! -perm 777 -type d -exec chmod 777 {} \; &

filenumber=`echo "$fn1 $fn2"|awk '{print($2-$1)}'`
#echo "$fn2, $fn1, $filenumber"
#read
filesize=$(($fs2-$fs1))
timediff=$(($t2-$t1))
#timediff=$(($ttmp-$t1))
#timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
if [ $timediff -eq 0 ]; then
  timediff=1
fi
  
speed=`echo "$filesize $timediff"|awk '{print($1/$2)}'`

today1=`date +%Y-%m-%d`
ctime3=`date  +%H:%M:%S`
#t3=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#t4=`echo $ctime3|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#t4=`date +%s`
endtime=`date +%s`
timediff1=`echo "$starttime $endtime"|awk '{print($2-$1)}'`

echo " " 
echo "$today1 $ctime3: Succeeded in Syncing $datatype data @ FSO!"
echo "Synced file No.  : $filenumber file(s)"
echo "            size : $filesize MB"
echo "    Sync @ Speed : $speed MB/s"
echo "       Time Used : $timediff secs."
echo " Total Time Used : $timediff1 secs."
echo "            From : $today0 $ctime0 "
echo "              To : $today1 $ctime3 "
rm -rf $lockfile
cd /home/chd/
exit 0



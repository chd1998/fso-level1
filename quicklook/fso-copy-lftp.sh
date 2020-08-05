#!/bin/bash
#author: chen dong @fso
#Copy specified date TIO/HA data on remote host to /lustre/data mannually
#Usage: ./fso-copy-lftp.sh srcip port  dest year(4 digits) monthday(4 digits) user password datatype(TIO/HA)
#Example: ./fso-copy-lftp.sh 192.168.111.120 21 /lustre/data 2019 0427 tio ynao246135 TIO
#changlog: 
#        20190420       Release 0.1   first prototype release 0.1
#        20190421       Release 0.2   fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
#        20190423       Release 0.3   fix errors
#        20190426       Release 0.4   fix errors
#        20190428       Release 0.5   add monthday to the src dir
#                       Release 0.6   datatype is an option now
#        20190603       Release 0.7   using lftp instead of wget
#        20190604       Release 0.8   add progress bar to lftp
#        20190608       Release 0.9   fixed error in directory
#                       Release 1.0   improve display info
#        20190702       Release 1.1   revise some logical relations
#        20190704       Release 1.2   using lftp & add input args
#        20190705       Release 1.3   logics revised
#                       Release 1.4   revise timing logics
#        20191015               1.41  revised time calculation
#        20200103       Release 1.42  modified to use for ha levle quicklook
#        20200430       Release 1.43  add ping to test server online and other minor correction
#        20200520       Release 1.44  fixed minor errors in displaying
#        20200805       Release 1.45  exclude *_redata in syncing
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
  wctime=`date --date='0 days ago' +%H:%M:%S`
  wtoday=`date --date='0 days ago' +%Y%m%d`
  echo "$wtoday $wctime: $2 Task Has Done!"
#  dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  dt1=`date +%s`
#  echo "                   Finishing..."
  kill -6 $tmppid >/dev/null 1>&2
  echo "$dt1" > $logpre/dtmp
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

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
today0=`date  +%Y-%m-%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
ctime0=`date --date='0 days ago' +%H:%M:%S`
tstart=`date +%s`

if [ $# -ne 8 ]  ;then
  echo "Copy specified date TIO/HA data on remote host to /lustre/data mannually"
  echo "Usage: ./fso-copy-lftp-v142.sh srcip port  dest year(4 digits) monthday(4 digits) user password datatype(TIO/HA)"
  echo "Example: ./fso-copy-lftp-v142.sh 192.168.100.238 21 /home/user/data 2020 0103 ha ynao246135 HA"
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
#ftpuser=$(echo $datatype|tr '[A-Z]' '[a-z]')

logpre=./log

ftpserver=ftp://$ftpuser:$password@$ftpserver:$remoteport
#echo "$ftpserver"
#read

lockfile=$logpre/$(basename $0)-$srcyear$srcmonthday.lock
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
progname=$(basename $0)
pversion=1.45
echo " "
echo "======== Welcome to FSO Data Copying System@FSO! ========"
echo "                                                         "
echo "              $progname                                  "
echo "                                                         "
echo "            Relase $pversion     20200520  14:22         "
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

ctime=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime: Syncing $datatype data @ FSO..."
echo "                   From: $srcdir@$server "
echo "                   To  : $destdir "
echo "                   Please Wait..."

fn1=`ls -lR $destdir | grep "^-" | wc -l`
fs1=`du -sm $destdir | awk '{print $1}'`
ctime=`date --date='0 days ago' +%H:%M:%S`

lftp $ftpserver -e "mirror -X dark/* -X flat/* -X Dark/* -X FLAT*/* -X *_redata/*  --only-missing --parallel=20 $srcdir1  $destdir; quit" >/dev/null 2>&1 &
#lftp $ftpserver -e "mirror --parallel=40 $srcdir1  $destdir; quit" >/dev/null 2>&1 &
waiting "$!" "$datatype Syncing" "Syncing $datatype Data"
if [ $? -ne 0 ];then
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime1: Failed in Syncing $datatype Data from $srcdir to $destdir"
  #cd /home/
  exit 1
fi

ttmp=$(cat $logpre/dtmp)

ctime1=`date --date='0 days ago' +%H:%M:%S`
t1=`date +%s`
#t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`

targetdir=${destdir}
ls -lR $targetdir | grep "^-" | wc -l > $logpre/tmpfn2.dat &
waiting "$!" "File Number Sumerizing" "Sumerizing File Number"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Number of $datatype Failed!"
  cd /home/chd/
  exit 1
fi

#fn1=$(cat $logpre/tmpfn1.dat)
fn2=$(cat $logpre/tmpfn2.dat)


du -sm $targetdir|awk '{print $1}' > $logpre/tmpfs2.dat &
waiting "$!" "File Size Summerizing" "Sumerizing File Size"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Size of $datatype Failed!"
  cd /home/chd/
  exit 1
fi
if [ ! -d "$targetdir" ]; then
  echo "0" > $logpre/tmpfs.dat
fi  

#fs1=$(cat $logpre/tmpfs1.dat)
fs2=$(cat $logpre/tmpfs2.dat)

#chmod 777 -R $destdir &
find $targetdir ! -perm 777 -type f -exec chmod 777 {} \; &
find $targetdir ! -perm 777 -type d -exec chmod 777 {} \; &

filenumber=`echo "$fn1 $fn2"|awk '{print($2-$1)}'`
#echo "$fn2, $fn1, $filenumber"
#read
filesize=$(($fs2-$fs1))
if [ $filesize -lt 0 ]; then
  filesize=0
fi
timediff=$(($ttmp-$t1))
#timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
if [ $timediff -eq 0 ]; then
  timediff=1
fi
  
speed=`echo "$filesize $timediff"|awk '{print($1/$2)}'`

today1=`date +%Y-%m-%d`
ctime3=`date --date='0 days ago' +%H:%M:%S`
#t3=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#t4=`echo $ctime3|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
tend=`date +%s`
timediff1=`echo "$tstart $tend"|awk '{print($2-$1)}'`

echo " " 
echo "$today $ctime3: Succeeded in Syncing $datatype data @ FSO!"
echo "Synced file No.  : $filenumber file(s)"
echo "            size : $filesize MB"
echo "    Sync @ Speed : $speed MB/s"
echo "       Time Used : $timediff secs."
echo " Total Time Used : $timediff1 secs."
echo "            From : $today0 $ctime0 "
echo "              To : $today1 $ctime3 "
rm -rf $lockfile
#cd /home/chd/
exit 0



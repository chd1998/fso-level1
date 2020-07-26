#!/bin/bash
#author: chen dong @fso
#purposes: manually syncing TIO/HA data in specified year(eg., 2019...) from remoteip to local lustre storage via lftp
#Usage: ./fso-copy-log-cyg.sh srcip dest year(4 digits)  monthday(4 digits) user passwd datatype(TIO/HA)
#Example: ./fso-copy-log-cyg.sh ftp://192.168.111.120 e 2019 0907 tio ynao246135 TIO
#changlog: 
#        20200521       Relaase 0.1 	first version under cygwin
#
#waiting pid taskname prompt
waiting() {
#	tput sc
  local pid="$1"
  taskname="$2"
  procing "$3" &
  local tmppid="$!"
  wait $pid
# restore cur pos
#  tput rc
#  tput ed
	wctime=`date --date='0 days ago' +%H:%M:%S`
	wtoday=`date --date='0 days ago' +%Y%m%d`
	
	echo -e "\n$wtoday $wctime: $2 Task Has Done!"
	echo "                   Finishing..."
  dt1=`date +%s`
  #dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  
  kill -6 $tmppid >/dev/null 1>&2
  echo "$dt1" > $logpath/$(basename $0)_${datatype}_dtmp.dat
}

procing() {
        trap 'exit 0;' 6
        #tput ed
        while [ 1 ]
        do
        	tput sc
        	tput ed
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

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    exit 1
}

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
ctime0=`date --date='0 days ago' +%H:%M:%S`

if [ $# -ne 8 ]  ;then
  echo "Copy specified date TIO/HA data log on remote host to local HD under cygwin"
  echo "Usage: ./fso-copy-log-cyg.sh srcip port dest year(4 digits)  monthday(4 digits) user password datatype(TIO/HA)"
  echo "Example: ./fso-copy-log-cyg.sh 192.168.111.120 21 f 2019 0713 tio ynao246135 TIO"
  exit 1
fi

procName=$(basename $0)
pversion=0.1

syssep="/"
dest00="/cygdrive/"
ftpserver=$1
remoteport=$2
destpre=${dest00}$3
srcyear=$4
srcmonthday=$5
ftpuser=$6
password=$7
datatype=$8
#ftpuser=$(echo $datatype|tr '[A-Z]' '[a-z]')

ftpserver=ftp://$ftpuser:$password@$ftpserver:$remoteport
#echo "$ftpserver"
#read

homepre="/home/chd"
logpath=$homepre/log

lockfile=$logpath/$(basename $0)_${datatype}-$today.lock
if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    echo "$today $ctime: $(basename $0) is running for syncing $datatype data... " && exit 1
  else
    echo $$>$lockfile
  fi
else
  echo $$>$lockfile
fi

echo " "
echo "======== Welcome to FSO Data Copying System@FSO! ========"
echo "                                                         "
echo "                 $procName                               "  
echo "                                                         "
echo "             Relase $pversion     20200521  13:24        "
echo "         Copy the $datatype data log from remote         "
echo "                                                         "
echo "                $today    $ctime                         "
echo "                                                         "
echo "========================================================="
echo " "
#procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
#pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
#if [ $procCmd -le 0 ];then
#destdir=${destpre}${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
destdir=${destpre}${syssep}${syssep}${datatype}-log${syssep}
#remotesrcdir=${syssep}${srcyear}${srcmonthday}${syssep}${datatype}$
srcdir=${ftpserver1}${syssep}${srcyear}${srcmonthday}${syssep}ftpuser_${srcyear}${srcmonthday}_log.txt
#srcdir1=${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
srcdir1=${syssep}${srcyear}${srcmonthday}${syssep}

if [ ! -d "$destdir" ]; then
  mkdir -p $destdir
else
  echo "$destdir already exist!"
fi

ctime=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime: Copying $datatype data log @ FSO..."
echo "                   From: $srcdir1 "
echo "                   To  : $destdir "
echo "                   Please Wait..."

ctime=`date --date='0 days ago' +%H:%M:%S`
t1=`date +%s`

lftp $ftpserver -e "mirror  --ignore-time --continue --parallel=40 $srcdir1  $destdir; quit" >/dev/null 2>&1 &
waiting "$!" "$datatype Syncing" "Syncing $datatype Data"
if [ $? -ne 0 ];then
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime1: Failed in Syncing $datatype Data from $srcdir to $destdir"
  #cd /home/chd
  exit 1
fi

ttmp=$(cat $logpath/$(basename $0)_${datatype}_dtmp.dat)

ctime1=`date --date='0 days ago' +%H:%M:%S`
#t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`

#t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`


targetdir=${destdir}
ls -lR $targetdir | grep "^-" | wc -l > $logpath/$(basename $0)_${datatype}_tmpfn2.dat &
waiting "$!" "File Number Sumerizing for Synced $datatype Data" "Sumerizing File Number for Synced $datatype Data"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Number of $datatype Failed!"
  #cd /home/chd/
  exit 1
fi

#fn1=$(cat /home/chd/log/tmpfn1.dat)
fn2=$(cat $logpath/$(basename $0)_${datatype}_tmpfn2.dat)


du -sm $targetdir|awk '{print $1}' > $logpath/$(basename $0)_${datatype}_tmpfs2.dat &
waiting "$!" "File Size Summerizing for Synced $datatype Data" "Sumerizing File Size for Synced $datatype Data"
if [ $? -ne 0 ];then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Size of $datatype Failed!"
  #cd /home/chd/
  exit 1
fi
if [ ! -d "$targetdir" ]; then
  echo "0" > $logpath/$(basename $0)_${datatype}_tmpfs.dat
  echo "0" > $logpath/$(basename $0)_${datatype}_tmpfs2.dat
fi  

#fs1=$(cat /home/chd/log/tmpfs1.dat)
fs2=$(cat $logpath/$(basename $0)_${datatype}_tmpfs2.dat)

#chmod 777 -R $destdir &
#waiting "$!" "Permission Changing" "Changing Permission"
#if [ $? -ne 0 ];then
#  ctime3=`date --date='0 days ago' +%H:%M:%S`
#  echo "$today $ctime3: Sumerizing File Number of $datatype Failed!"
#  cd /home/chd/
#  exit 1
#fi

filenumber=`echo "$fn1 $fn2"|awk '{print($2-$1)}'`
#echo "$fn2, $fn1, $filenumber"
#read
filesize=$(($fs2-$fs1))
timediff=$(($ttmp-$t1))
#timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
if [ $timediff -le 0 ]; then
  timediff=1
fi
  
speed=`echo "$filesize $timediff"|awk '{print($1/$2)}'`

today0=`date --date='0 days ago' +%Y%m%d`
ctime3=`date --date='0 days ago' +%H:%M:%S`
#t3=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#t4=`echo $ctime3|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t4=`date +%s`
timediff1=`echo "$t1 $t4"|awk '{print($2-$1)}'`

echo " " 
echo "$today0 $ctime3: Succeeded in Syncing $datatype data @ FSO!"
echo "          Synced : $filenumber file(s)"
echo "                 : $filesize MB"
echo "         @ Speed : $speed MB/s"
echo "       Time Used : $timediff secs."
echo "   Total  Synced : $fn2 file(s)"
echo "                 : $fs2 MB"
echo " Total Time Used : $timediff1 secs."
echo "            From : $today $ctime0 "
echo "              To : $today0 $ctime3 "
#rm -rf $logpath/$lockfile
#rm -rf $logpath/$(basename $0)_${datatype}_*.dat
#rm -rf $logpath/$(basename $0)_*.log
exit 0



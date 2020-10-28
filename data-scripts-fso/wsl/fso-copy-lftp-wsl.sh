#!/bin/bash
#author: chen dong @fso
#purposes: manually syncing TIO/HA data in specified year(eg., 2019...) from remoteip to local lustre storage via lftp
<<<<<<< HEAD
#Usage: ./fso-copy-lftp.cyg.sh srcip dest year(4 digits)  monthday(4 digits) user passwd datatype(TIO/HA)
#Example: ./fso-copy-lftp-cyg.sh ftp://192.168.111.120 e 2019 0907 tio ynao246135 TIO
=======
#Usage: ./fso-copy-lftp-wsl.sh srcip dest year(4 digits)  monthday(4 digits) user passwd datatype(TIO/HA)
#Example: ./fso-copy-lftp-cyg.sh 192.168.111.120 21 e 2020 1020 tio ynao246135 TIO"
#         ./fso-copy-lftp-cyg.sh 192.168.111.122 21 f 2020 1020 ha ynao246135 HA"
>>>>>>> 1be539e39b3377e93cae113b48242ea3868f0e9c
#changlog: 
#        20190420       Release 0.1.0 first prototype release 0.1
#        20190421       Release 0.2.0 fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
#        20190423       Release 0.3.0 fix errors
#        20190426       Release 0.4.0 fix errors
#        20190428       Release 0.5.0 add monthday to the src dir
#                       Release 0.6.0 datatype is an option now
#        20190603       Release 0.7.0 using lftp instead of wget
#        20190604       Release 0.8.0 add progress bar to lftp
#        20190608       Release 0.9.0 fixed error in directory
#                       Release 1.0.0 improve display info
#        20190702       Release 1.1.0 revise some logical relations
#        20190704       Release 1.2.0 using lftp & add input args
#        20190705       Release 1.3.0 logics revised
#                       Release 1.4.0 revise timing logics
#        20190713       Release 1.5.0 modified to use under cygwin
#        20201020       Release 1.5.1 modified to use under wsl on win10 
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
  echo "Copy specified date TIO/HA data on remote host to local HD under cygwin"
  echo "Usage: ./fso-copy-lftp-cyg.sh srcip port dest year(4 digits)  monthday(4 digits) user password datatype(TIO/HA)"
<<<<<<< HEAD
  echo "Example: ./fso-copy-lftp-cyg.sh 192.168.111.120 21 f 2019 0713 tio ynao246135 TIO"
=======
  echo "Example: ./fso-copy-lftp-cyg.sh 192.168.111.120 21 e 2020 1020 tio ynao246135 TIO"
  echo "         ./fso-copy-lftp-cyg.sh 192.168.111.122 21 f 2020 1020 ha ynao246135 HA"
>>>>>>> 1be539e39b3377e93cae113b48242ea3868f0e9c
  exit 1
fi

#procName="lftp"

syssep="/"
dest00="/mnt/"
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
pver=1.5.1
<<<<<<< HEAD
pname="fso-copy-lftp-wsl.sh"
=======
pname=$(basename $0)
>>>>>>> 1be539e39b3377e93cae113b48242ea3868f0e9c

echo " "
echo "============ Welcome to FSO Data System@FSO! ============"
echo "                                                         "
echo "                 $pname                   "  
echo "                                                         "
echo "             Release $pver     20191020  10:20           "
echo "     Sync $datatype data from $1 to $destpre  "
echo "                                                         "
echo "                $today    $ctime                         "
echo "                                                         "
echo "========================================================="
echo " "
#procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
#pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
#if [ $procCmd -le 0 ];then
#destdir=${destpre}${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
destdir=${destpre}${syssep}${srcyear}${srcmonthday}${syssep}
#remotesrcdir=${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
srcdir=${ftpserver1}${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
#srcdir1=${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
srcdir1=${syssep}${srcyear}${srcmonthday}${syssep}

if [ ! -d "$destdir" ]; then
  mkdir -p $destdir
else
  echo "$destdir already exist!"
fi

ctime=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime: Syncing $datatype data @ FSO..."
echo "                   From: $srcdir1 "
echo "                   To  : $destdir "
echo "                   Please Wait..."

#count existed file number
if [ ! -f "$logpath/$(basename $0)_${datatype}_tmpfn2.dat" ]; then
  #ls -lR $destdir | grep "^-" | wc -l > $logpath/$(basename $0)_${datatype}_tmpfn2.dat  & 
  #waiting "$!" "Existed $datatype File Number @ Dest Counting" "Counting Existed $datatype File Number @ Dest"
  echo "0" > $logpath/$(basename $0)_${datatype}_tmpfn2.dat
fi
fn1=$(cat $logpath/$(basename $0)_${datatype}_tmpfn2.dat)

#count existed file size  
if [ ! -f "$logpath/$(basename $0)_${datatype}_tmpfs2.dat" ]; then
  #fs1=`du -sm $destdir | awk '{print $1}'` > $logpath/$(basename $0)_${datatype}_tmpfs2.dat &
  #waiting "$!" "Existed $datatype File Size @ Dest Counting" "Counting Existed $datatype Dest File Size"
  echo "0" > $logpath/$(basename $0)_${datatype}_tmpfs2.dat
fi
fs1=$(cat $logpath/$(basename $0)_${datatype}_tmpfs2.dat)

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



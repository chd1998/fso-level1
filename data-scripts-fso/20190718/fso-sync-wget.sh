#!/bin/bash
#author: chen dong @ fso
#purposes: periodically syncing data from remoteip to local lustre storage via wget
#usage:  run in crontab every 1 min.  from 08:00-20:00
#example: none
#changlog: 
#      	20190603	Release 0.1     first version for tio-sync.sh
#	20190625	Release 0.2	revised lftp performance & multi-thread
#       20190702        Release 0.3     back to use wget in case of lftp failure 

#waiting pid taskname prompt
waiting() {
        local pid="$1"
        taskname="$2"
#        msg "$2... ..." '' -n
#        echo "$2..."
        procing "$3" &
        local tmppid="$!"
        wait $pid
        #恢复光标到最后保存的位置
#        tput rc
#        tput ed
	ctime=`date --date='0 days ago' +%H:%M:%S`
	today=`date --date='0 days ago' +%Y%m%d`
               
        echo "$today $ctime: $2 Task Has Done!"
        echo "                   Finishing...."
#        msg "done" $boldblue
        kill -6 $tmppid >/dev/null 1>&2
}

    #   输出进度条, 小棍型
procing() {
        trap 'exit 0;' 6
 	      tput ed
        while [ 1 ]
        do
		sleep 1
                today=`date --date='0 days ago' +%Y%m%d`
                ctime=`date --date='0 days ago' +%H:%M:%S`
                echo "$today $ctime: $1, Please Wait...   "
                #sleep 10
        done
}

procName="lftp"
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"

if [ $# -ne 5 ];then
  echo "Usage: ./fso-sync-wget.sh srcip destdir user password datatype(TIO or HA)"
  echo "Example: ./fso-sync-wget.sh  ftp://192.168.111.120 /lustre/data tio ynao246135 TIO"
  exit 1
fi

srcpre0=$1
destpre0=$2
user=$3
pasword=$4
datatype=$5
remoteport="21"

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

echo " "
echo "======= Welcome to Data Archiving System @ FSO! ======="
echo "                  fso-sync-wget.sh                     "
echo "          (Release 0.3 20190702 00:21)                 "
echo "                                                       "
echo "         sync $datatype data to $destpre0              "
echo " "
echo "                $today $ctime                          "
echo "======================================================="
echo " "
#procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
#pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
#if [ $procCmd -le 0 ];then
destdir=${destpre0}${syssep}${cyear}${syssep}${today}${syssep}
destdir1=${destpre0}${syssep}${cyear}${syssep}
targetdir=${destdir}${datatype}
if [ ! -d "$targetdir" ]; then
  mkdir -m 777 -p $targetdir
else
  echo "$today $ctime: $targetdir exists!"
fi
#destdir=${destpre}${today}${syssep}
targetdir=${destdir}${datatype}
#srcdir=${srcpre0}${syssep}${today}${syssep}
srcdir1=${srcpre0}:${remoteport}${syssep}${today}${syssep}${datatype}

n1=$(cat $filenumber)
s1=$(cat $filesize)

#if [ ! -d "$destdir" ]; then
#  mkdir -p $destdir
#else
#  echo "$today $ctime: $destdir exists!"
#fi
ctime=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime: Syncing $datatype data @ FSO..."
echo "             From: $srcdir1 "
echo "             To  : $targetdir "
echo "$today $ctime: Sync Task Started, Please Wait ... "
cd $targetdir
ctime1=`date --date='0 days ago' +%H:%M:%S`
mytime1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#lftp -e "mirror --ignore-time --no-perms --continue --no-umask --allow-chown --exclude '[RECYCLE]' --exclude System\ Volume\ Information/ --parallel=30  / .; quit" ftp://tio:ynao246135@192.168.111.120:21/
#lftp -u $user,$password -e "mirror --ignore-time --continue --no-perms --no-umask --allow-chown --allow-suid --parallel=40  . .; quit" $srcdir1 >/dev/null 2>&1 &
#waiting "$!" "$datatype Syncing" "Syncing $datatype Data"
wget  --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=tio --ftp-password=ynao246135 --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob --preserve-permissions $srcdir1  >/dev/null 2>&1 &
waiting "$!" "$datatype Syncing" "Syncing $datatype Data"
ctime3=`date --date='0 days ago' +%H:%M:%S`
if [ $? -ne 0 ];then
  echo "$today $ctime3: Syncing $datatype Data @ FSO Failed!"
  cd /home/chd/
  exit 1
fi
ctime2=`date --date='0 days ago' +%H:%M:%S`
mytime2=`echo $ctime3|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`

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
if [ $timediff -eq 0 ]; then
	speed=0
else
	speed=`echo "$ss $timediff"|awk '{print($1/$2)}'`
fi
echo $n2>$filenumber
echo $s2>$filesize

ctime2=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime2: Succeeded in Syncing $datatype data @ FSO!"
echo "          Synced : $sn file(s)"
echo "          Synced : $ss MB "
echo "       Time used : $timediff secs."
echo "           Speed : $speed MB/s"
echo "      Total file : $n2 file(s)"
echo "      Total size : $s2 MB"
echo "       Time from : $ctime1"
echo "              to : $ctime3"
echo "======================================================="
rm -rf $lockfile
cd /home/chd/
exit 0
#else
#  echo "$today $ctime: $procName  is running..."
#  echo "              PID: $pid                    "
#  exit 0
#fi


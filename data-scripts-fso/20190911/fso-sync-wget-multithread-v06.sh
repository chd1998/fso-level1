#!/bin/bash
#author: chen dong @ fso
#purposes: periodically syncing data from remoteip to local lustre storage via wget
#usage:  run in crontab every 1 min.  from 08:00-20:00
#example: none
#changlog:
#      	20190603  Release 0.1     first version for tio-sync.sh
#       20190625  Release 0.2	  revised lftp performance & multi-thread
#       20190702  Release 0.3     back to use wget in case of lftp failure
#                 Release 0.4     multithread with wget
#                 Release 0.5     threadnumber input
#       20190717  Release 0.6     revised multithread performance
#       
#

#waiting pid taskname prompt

waiting() {
        local pid="$1"
        taskname="$2"
#        msg "$2... ..." '' -n
#        echo "$2..."
        procing "$3" &
        local tmppid="$!"
        wait $pid
        #�ָ���굽��󱣴��λ��
#        tput rc
#        tput ed
         pctime=`date  +%H:%M:%S`
         ptoday=`date  +%Y%m%d`

         echo "$ptoday $pctime: $2 Task Has Done!"
         echo "                   Finishing...."
#        msg "done" $boldblue
         kill -6 $tmppid >/dev/null 1>&2
}

    #   ���������, С����
procing() {
        trap 'exit 0;' 6
        tput ed
        while [ 1 ]
        do
            sleep 1
            prtoday=`date  +%Y%m%d`
            prctime=`date  +%H:%M:%S`
            echo "$prtoday $prctime: $1, Please Wait...   "
            #sleep 10
        done
}


cyear=`date  +%Y`
today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
syssep="/"
threadnumber=5
#default value of thread number: 5
if [ $# -ne 7 ];then
  echo "Usage: ./fso-sync-wget-multithread-vxx.sh srcip port destdir user password datatype(TIO or HA) threadnumber"
  echo "Example: ./fso-sync-wget-multithread-vxx.sh  ftp://192.168.111.120 21 /lustre/data tio ynao246135 TIO 5"
  exit 1
fi

srcpre0=$1
remoteport=$2
destpre0=$3
user=$4
pasword=$5
datatype=$6
threadnumber=$7

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
echo "           fso-sync-wget-multithread-v06.sh                "
echo "          (Release 0.6 20190717 21:12)                 "
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
  echo "$today $ctime: $destdir exists!"
fi
srcdir=${srcpre0}${syssep}${today}${syssep}
srcdir1=${srcpre0}:${remoteport}${syssep}${today}${syssep}${datatype}

n1=$(cat $filenumber)
s1=$(cat $filesize)

ctime=`date  +%H:%M:%S`
echo "$today $ctime: Syncing $datatype data @ FSO..."
echo "             From: $srcdir1 "
echo "             To  : $destdir "
echo "$today $ctime: Sync Task Started, Please Wait ... "
cd $destdir1
ctime1=`date  +%H:%M:%S`
mytime1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#lftp -e "mirror --ignore-time --no-perms --continue --no-umask --allow-chown --exclude '[RECYCLE]' --exclude System\ Volume\ Information/ --parallel=30  / .; quit" ftp://tio:ynao246135@192.168.111.120:21/
#lftp -u $user,$password -e "mirror --ignore-time --continue --no-perms --no-umask --allow-chown --allow-suid --parallel=40  . .; quit" $srcdir1 >/dev/null 2>&1 &
#waiting "$!" "$datatype Syncing" "Syncing $datatype Data"
itmp=$threadnumber
while  [ $itmp -gt 0 ]
do
  #echo "Starting wget Thread: #$itmp..."
  wget  -q --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=$user --ftp-password=$password --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob --preserve-permissions $srcdir > /dev/null 2>&1 &
  itmp=$((itmp-1))
done
#wait for every wget thread to end
jobnumber=$(jobs -p | wc -l)
#echo "$jobnumber processes started!"
j=1
while [ $j -lt $jobnumber ]; do
  wait %$j
#  echo $?
  ((j++))
done

ctimethread=`date  +%H:%M:%S`
echo  "$today $ctimethread: $threadnumber wget threads ended..."


ctime3=`date  +%H:%M:%S`
if [ $? -ne 0 ];then
  echo "$today $ctime3: Syncing $datatype Data @ FSO Failed!"
  cd /home/chd/
  exit 1
fi
ctime2=`date  +%H:%M:%S`
mytime2=`echo $ctime3|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`

#chmod 777 -R $targetdir &
find $targetdir ! -perm 777 -type f -exec chmod 777 {} \; & 
find $targetdir ! -perm 777 -type d -exec chmod 777 {} \; &
#waiting "$!" "Permission Changing" "Changing Permission"
#if [ $? -ne 0 ];then
#  ctime3=`date  +%H:%M:%S`
#  echo "$today $ctime3: Changing Permission of $datatype Failed!"
#  cd /home/chd/
#  exit 1
#fi
ctime2=`date  +%H:%M:%S`
echo "$today $ctime2: Summerizing File Numbers & Size..."
#n2=`ls -lR $targetdir | grep "^-" | wc -l`
#s2=`du -sm $targetdir|awk '{print $1}'`

ls -lR $targetdir | grep "^-" | wc -l > $filenumber1 &
waiting "$!" "File Number Sumerizing" "Sumerizing File Number"
if [ $? -ne 0 ];then
  ctime3=`date  +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Number of $datatype Failed!"
  cd /home/chd/
  exit 1
fi

du -sm $targetdir|awk '{print $1}' > $filesize1 &
waiting "$!" "File Size Summerizing" "Sumerizing File Size"
if [ $? -ne 0 ];then
  ctime3=`date  +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Size of $datatype Failed!"
  cd /home/chd/
  exit 1
fi
if [ ! -d "$targetdir" ]; then
  echo "0" > $filesize1
  echo "0" > $filenumber1
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

ctime2=`date  +%H:%M:%S`
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
#cd /home/chd/
exit 0


#!/bin/bash
#author: chen dong @fso
#purposes: manually syncing TIO/HA data in specified year(eg., 2019...) from remoteip to local lustre storage via lftp
#Usage: ./fso-copy.sh srcip dest year(4 digits)  monthday(4 digits) datatype(TIO/HA)
#Example: ./fso-copy.sh ftp://192.168.111.120 /lustre/data 2019 0427 TIO
#changlog: 
#        20190420       Release 0.1 first prototype release 0.1
#        20190421       Release 0.2 fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
#        20190423       Release 0.3 fix errors
#        20190426       Release 0.4 fix errors
#        20190428       Release 0.5 add monthday to the src dir
#                       Release 0.6 datatype is an option now
#        20190603       Release 0.7 using lftp instead of wget
#        20190604       Release 0.8 add progress bar to lftp
#        20190608       Release 0.9 fixed error in directory
#                       Release 1.0 improve display info
#        20190702       Release 1.1 revise some logical relations
#        20190703       Release 1.2 using wget in case of lftp failure
#                       Release 1.3 using multiple wget
#        20190719       Release 1.4 revised multi wget performance
#        20200615       Release 1.5 fixed some minor errors
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
	ctime=`date  +%H:%M:%S`
	today=`date  +%Y%m%d`
        echo "$today $ctime: $2 Task Has Done!"
#        echo "                   Finishing..."
        kill -6 $tmppid >/dev/null 1>&2
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
                sleep 1
                tput rc
          done
        done
}

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    #umount $dev
    exit 1
}

cyear=`date  +%Y`
today=`date  +%Y%m%d`
starttime=`date  +%H:%M:%S`

if [ $# -ne 9 ]  ;then
  echo "Copy specified date TIO/HA data on remote host to /lustre/data mannually"
  echo "Usage: ./fso-copy-wget.sh srcip port user passwd dest year(4 digits)  monthday(4 digits) datatype(TIO/HA) threadnumber"
  echo "Example: ./fso-copy-wget.sh ftp://192.168.111.120 21 tio ynao246135 /lustre/data 2019 0703 TIO 5"
  exit 1
fi

#procName="lftp"
syssep="/"

ftpserver=$1
remoteport=$2
ftpuser=$3
password=$4
destpre0=$5
srcyear=$6
srcmonthday=$7
datatype=$8
threadnumber=$9

tmpfn=/home/chd/log/$(basename $0)-$datatype-tmpfn.dat
tmpfs=/home/chd/log/$(basename $0)-$datatype-tmpfs.dat

lockfile=/home/chd/log/$(basename $0)-$datatype.lock
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

progver=1.5

echo " "
echo "============= Welcome to FSO Data System@FSO! ============="
echo "                                                           "
echo "                  $(basename $0)                           "  
echo "                                                           "
echo "             Relase $progver     20200615 06:26            "
echo "                                                           "
echo "                $today    $starttime                       "
echo "                                                           "
echo "==========================================================="
echo " "
#procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
#pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
#if [ $procCmd -le 0 ];then
destdir=${destpre0}${syssep}${srcyear}${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
#remotesrcdir=${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
ftpserver1=${ftpserver}:${remoteport}
srcdir=${ftpserver1}${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}
srcdir1=${syssep}${srcyear}${srcmonthday}${syssep}${datatype}${syssep}

if [ ! -d "$destdir" ]; then
  mkdir -p -m 777 $destdir
else
  echo "$destdir already exist!"
fi

curday=`date +%Y%m%d`

ctime=`date  +%H:%M:%S`
echo "$curday $ctime: Syncing $datatype data @ FSO..."
echo "                   From: $srcdir "
echo "                   To  : $destdir "
#  echo ""
#  read
cd $destdir
#t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t1=`date +%s`
itmp=$threadnumber
while  [ $itmp -gt 0 ]
do
  ctimet=`date  +%H:%M:%S`
  curday=`date +%Y%m%d`
  echo "$curday $ctimet: Starting wget process: $itmp..."
  wget  -q --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=$ftpuser --ftp-password=$password --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob --preserve-permissions $srcdir > /dev/null 2>&1 &
  itmp=$((itmp-1))
done
#wait for every wget process to end
ctimet=`date  +%H:%M:%S`
curday=`date +%Y%m%d`
jobnumber=$(jobs -p | wc -l)
echo "$curday $ctimet: $jobnumber process(es) started!"
echo "                   Syncing $datatype from @ $srcdir, please wait..."
j=1
while [ $j -le $jobnumber ]; do
  ctimet=`date  +%H:%M:%S`
  curday=`date +%Y%m%d`
  wait %$j 
  echo "$curday $ctimet: Process $j exited with $?..."
  ((j++))
done

#while [ $itmp -gt 0 ]
#do 
#  wget -q --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=$ftpuser --ftp-password=$password --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob $srcdir  >> $datatype.lock &
#  ctimet=`date  +%H:%M:%S`
#  echo "$today $ctimet: Start thread  $itmp for Syncing $datatype @ $srcdir1"
#  itmp=$((itmp-1))
#done
curday=`date +%Y%m%d`
ctimet=`date  +%H:%M:%S`
echo  "$curday $ctimet: $threadnumber wget process(es) finished..."

ctime1=`date  +%H:%M:%S`
#waiting "$!" "$datatype Syncing" "Syncing $datatype Data"
#echo "Please Wait..."
#if [ $? -ne 0 ];then
#  echo "$today $ctime1: Failed in Syncing $datatype Data from $srcdir to $destdir"
#  cd /home/chd
#  exit 1
#fi

#t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t2=`date +%s`
ctime2=`date  +%H:%M:%S`
targetdir=${destdir}
ls -lR $targetdir | grep "^-" | wc -l > $tmpfn &
waiting "$!" "File Number Sumerizing" "Sumerizing File Number"
if [ $? -ne 0 ];then
  ctime3=`date  +%H:%M:%S`
  curday=`date +%Y%m%d`
  echo "$curday $ctime3: Sumerizing File Number of $datatype Failed!"
  cd /home/chd/
  exit 1
fi
filenumber=$(cat $tmpfn)

du -sm $targetdir|awk '{print $1}' > $tmpfs &
waiting "$!" "File Size Summerizing" "Sumerizing File Size"
if [ $? -ne 0 ];then
  ctime3=`date  +%H:%M:%S`
  curday=`date +%Y%m%d`
  echo "$curday $ctime3: Sumerizing File Size of $datatype Failed!"
  cd /home/chd/
  exit 1
fi
if [ ! -d "$targetdir" ]; then
  echo "0" > $tmpfs
fi  

filesize=$(cat $tmpfs)

find $targetdir ! -perm 777 -type f -exec chmod 777 {} \; &
find $targetdir ! -perm 777 -type d -exec chmod 777 {} \; &

timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
if [ $timediff -le 0 ]; then
  speed=0
else
  speed=`echo "$filesize $timediff"|awk '{print($1/$2)}'`
fi

endtime=`date  +%H:%M:%S`
#t3=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#t4=`echo $ctime3|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t4=`date +%s`
timediff1=`echo "$t1 $t4"|awk '{print($2-$1)}'`

curday=`date +%Y%m%d`
echo " " 
echo "$curday $endtime: Succeeded in Syncing $datatype data @ FSO!"
echo "Synced file No.  : $filenumber file(s)"
echo "Synced data size : $filesize MB"
echo "           Speed : $speed MB/s"
echo "  Sync Time Used : $timediff secs."
echo " Total Time Used : $timediff1 secs."
echo "            From : $today $starttime  "
echo "              To : $curday $endtime "
echo "======================================================================"
rm -f $lockfile
rm -f $tmpfn
rm -f $tmpfs
cd /home/chd/
exit 0



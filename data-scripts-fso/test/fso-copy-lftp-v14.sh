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
#        20190704       Release 1.2 using lftp & add input args
#        20190705       Release 1.3 logics revised
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
        dt1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#        echo "                   Finishing..."
        kill -6 $tmppid >/dev/null 1>&2
        return $dt1
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
ctime=`date  +%H:%M:%S`
ctime0=`date  +%H:%M:%S`
if [ $# -ne 8 ]  ;then
  echo "Copy specified date TIO/HA data on remote host to /lustre/data mannually"
  echo "Usage: ./fso-copy-lftp.sh srcip port  dest year(4 digits) monthday(4 digits) user password datatype(TIO/HA)"
  echo "Example: ./fso-copy-lftp.sh 192.168.111.120 21 /lustre/data 2019 0427 tio ynao246135 TIO"
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

ftpserver=ftp://$ftpuser:$password@$ftpserver:$remoteport
#echo "$ftpserver"
#read

lockfile=/home/chd/log/$(basename $0)_lockfile
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

echo " "
echo "======== Welcome to FSO Data Copying System@FSO! ========"
echo "                                                         "
echo "                 fso-copy-lftp.sh                        "  
echo "                                                         "
echo "             Relase 1.3     20190705  17:21              "
echo " Copy the $datatype data from remote ftp site to lustre  "
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
echo "                     Please Wait..."
ls -lR $destdir | grep "^-" | wc -l > /home/chd/log/tmpfn1.dat
du -sm $targetdir|awk '{print $1}' > /home/chd/log/tmpfs1.dat
ctime=`date  +%H:%M:%S`
lftp $ftpserver -e "mirror  --only-missing --continue --parallel=40 $srcdir1  $destdir; quit" >/dev/null 2>&1 &
t2=`waiting "$!" "$datatype Syncing" "Syncing $datatype Data"`
echo $?
read
if [ $? -ne 0 ];then
  ctime1=`date  +%H:%M:%S`
  echo "$today $ctime1: Failed in Syncing $datatype Data from $srcdir to $destdir"
  cd /home/chd
  exit 1
fi


ctime1=`date  +%H:%M:%S`
t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
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
fn1=$(cat /home/chd/log/tmpfn1.dat)
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

fs1=$(cat /home/chd/log/tmpfs1.dat)
fs2=$(cat /home/chd/log/tmpfs2.dat)

chmod 777 -R $destdir &
waiting "$!" "Permission Changing" "Changing Permission"
if [ $? -ne 0 ];then
  ctime3=`date  +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Number of $datatype Failed!"
  cd /home/chd/
  exit 1
fi

filenumber=$(($fn2-$fn1))
filesize=$(($fs2-$fs1))
timediff=$(($t2-$t1))
#timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
if [ $timediff -eq 0 ]; then
  timediff=1
fi
  
speed=`echo "$filesize $timediff"|awk '{print($1/$2)}'`


ctime3=`date  +%H:%M:%S`
#t3=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t4=`echo $ctime3|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
timediff1=`echo "$t1 $t4"|awk '{print($2-$1)}'`

echo " " 
echo "$today $ctime3: Succeeded in Syncing $datatype data @ FSO!"
echo "Synced file No.  : $filenumber file(s)"
echo "Synced data size : $filesize MB"
echo "    Sync @ Speed : $speed MB/s"
echo "  Sync Time Used : $timediff secs."
echo " Total Time From : $ctime0 "
echo "              To : $ctime3 "
rm -rf $lockfile
cd /home/chd/
exit 0



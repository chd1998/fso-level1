#!/bin/bash
#author: chen dong @fso
#purposes: periodically syncing data from remoteip to local lustre storage via lftp
#
#changlog: 
#       20190603    Release 0.1.0     first version for tio-sync.sh
#       20190625    Release 0.2.0     revised lftp performance & multi-thread
#       20190703    Release 0.3.0     fix some errors 
#       20190705    Release 0.4.0     timing logic revised
#       20190715    Release 0.5.0     reduce time of changing permission
#       20190716    Release 0.6.0     add parallel permission changing
#                   Release 0.7.0     input parallel lftp thread number
#       20190718    Release 0.8.0     add remote data info 
<<<<<<< HEAD
#       20190914    Release 0.9.0     revised display info and some minor errors
#       20191015    Release 0.9.1     correct the time calculating
#       20200607    Release 0.9.2     correct minor errors
#       20200615    Release 0.9.3     add ping test
#       20200928    Release 0.9.4     using ls -alR to get real size of files
#       20201106    Release 0.9.5     fixed display info errors
=======
#       20190914    Release 0.9.0    revised display info and some minor errors
#       20191015    Release 0.9.1    correct the time calculating
#       20200607    Release 0.9.2    correct minor errors
#       20200615    Release 0.9.3    add ping test
#       20200928    Release 0.9.4    using ls -alR to get real size of files
#       20201106    Release 0.9.5
>>>>>>> 8df67062650330952695939c3fe8e2442a53ab15
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
  #dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  dt1=`date +%s`
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
today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
syssep="/"

if [ $# -ne 7 ];then
  echo "Usage: ./fso-sync-lftp-v09.sh ip port  destdir user password datatype(TIO or HA) threadnumber"
  echo "Example: ./fso-sync-lftp-v09.sh  192.168.111.120 21 /lustre/data tio ynao246135 TIO 40"
  echo "         ./fso-sync-lftp-v09.sh  192.168.111.122 21 /lustre/data ha ynao246135 HA 40"
  exit 1
fi
server1=$1
port=$2
destpre0=$3
user=$4
password=$5
datatype=$6
pnum=$7

server=${server1}:${port}

#umask 0000
logpre=/home/chd/log

filenumber=/home/chd/log/$(basename $0)-$datatype-number.dat
filesize=/home/chd/log/$(basename $0)-$datatype-size.dat
filenumber1=/home/chd/log/$(basename $0)-$datatype-number-1.dat
filesize1=/home/chd/log/$(basename $0)-$datatype-size-1.dat

srcsize=/home/chd/log/$datatype-$today-$server1-filesize.dat
srcnumber=/home/chd/log/$datatype-$today-$server1-filenumber.dat

lockfile=/home/chd/log/$(basename $0)-$datatype-$today.lock


#if [ ! -f $filenumber ];then
#  echo "0">$filenumber
#fi
#if [ ! -f $filesize ];then 
#  echo "0">$filesize
#fi
#if [ ! -f $filenumber1 ];then
#  echo "0">$filenumber1
#fi
#if [ ! -f $filesize1 ];then
#  echo "0">$filesize1
#fi

if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    echo "$today $ctime: $(basename $0) is running for syncing $datatype data..." 
    exit 1
  else
    echo $$>$lockfile
    echo "0">$filenumber
    echo "0">$filesize
    echo "0">$filenumber1
    echo "0">$filesize1
  fi
else
  echo $$>$lockfile
  echo "0">$filenumber
  echo "0">$filesize
  echo "0">$filenumber1
  echo "0">$filesize1
fi

pver=0.9.5

#st1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
tstart=`date +%s`
ctime=`date  +%H:%M:%S`
echo "                                                       "
echo "============ Welcome to Data System @ FSO! ============"
echo "                 $(basename $0)                        "
echo "            (Release $pver 20201106 16:18)             "
echo "                                                       "
echo "              sync $datatype data to $destpre0         "
echo "                                                       "
echo "               Started @ $today $ctime                 "
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
srcdir0=${syssep}${today}${syssep}
srcdir1=${srcpre0}

n1=$(cat $filenumber)
s1=$(cat $filesize)
cd $targetdir
ctime=`date  +%H:%M:%S`
echo "$today $ctime: Syncing $datatype data @ FSO..."
echo "             From: $server$srcdir "
echo "             To  : $targetdir "

#echo "$today $ctime: Testing $server1 is online or not... "
#ping $server1 -c 5 | grep ttl >> $logpre/pingtmp
#pingres=`cat $logpre/pingtmp | wc -l`
#rm -f $logpre/pingtmp
ctime1=`date  +%H:%M:%S`
today=`date  +%Y%m%d`
#if [ $pingres -eq 0 ];then
#  echo "$today $ctime1: $server1 is offline, skip syncing remote file(s)..." 
  #exit 0
#else
#echo "$today $ctime1: $server1 is online, proceed to sync remote file(s)..."
#echo "                 : pls wait....."
#echo "$today $ctime1: Sync Task Started, Please Wait ... "
#cd $destdir
#ctime1=`date  +%H:%M:%S`
 #mytime1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
syncstart=`date +%s`
server=ftp://$user:$password@$server
#lftp  $server -e "mirror --ignore-time --continue  --parallel=$pnum  $srcdir $targetdir; quit">/dev/null 2>&1 &
lftp  $server -e "mirror  -x '^\.' --parallel=$pnum  $srcdir0 $destdir; quit">/dev/null 2>&1 &
#lftp -p 2121 -u tio,ynao246135 -e "mirror --only-missing --continue  --parallel=40  /20190704/TIO /lustre/data/2019/20190704/TIO; quit" ftp://192.168.111.120 >/dev/null 2>&1 &
#wget  --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=tio --ftp-password=ynao246135 --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob --preserve-permissions $srcdir1
waiting "$!" "$datatype Syncing" "Syncing $datatype Data"
ctime3=`date  +%H:%M:%S`
if [ $? -ne 0 ];then
  echo "$today $ctime3: Syncing $datatype Data @ FSO Failed!"
  cd /home/chd/
  exit 1
fi
ctime2=`date  +%H:%M:%S`
syncend=`date +%s`
#fi
  
ctime2=`date  +%H:%M:%S`
echo "$today $ctime2: Summerizing $datatype File Numbers & Size..."
#n2=`ls -lR $targetdir | grep "^-" | wc -l` 
#s2=`du -sm $targetdir|awk '{print $1}'` 

#filetmp=${target}${syssep}*.fits
cd $targetdir
find $targetdir -name *.fits -type f | wc -l > $filenumber1 &
waiting "$!" "$datatype File Number Sumerizing" "Sumerizing $datatype File Number"
if [ $? -ne 0 ];then
  ctime3=`date  +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Number of $datatype Failed!"
  cd /home/chd/
  exit 1
fi
du -sm $targetdir/|awk '{print $1}' > $filesize1 &
#cd $targetdir
#find $targetdir -name *.fits -type f | xargs -I {} ls -al|awk '{sum += $5} END {print sum/(1024*1024)}' > $filesize1 &
waiting "$!" "$datatype File Size Summerizing" "Sumerizing $datatype File Size"
if [ $? -ne 0 ];then
  ctime3=`date  +%H:%M:%S`
  echo "$today $ctime3: Sumerizing File Size of $datatype Failed!"
  cd /home/chd/
  exit 1
fi

#if [ ! -d "$targetdir" ]; then
#  echo "0" > $filesize1
#  echo "0" > $filenumber1
#fi

find $targetdir ! -perm 777 -type d -exec chmod 777 {} \; &

n2=$(cat $filenumber1)
s2=$(cat $filesize1)

sn=`echo "$n1 $n2"|awk '{print($2-$1)}'`
if [ $sn -le 0 ];then
  ss=0
  sn=0
else
  ss=`echo "$s1 $s2"|awk '{print($2-$1)}'`
fi 

synctime=`echo "$syncstart $syncend"|awk '{print($2-$1)}'`
if [ $synctime -le 0 ];then
  synctime=0
  speed=0
  ss=0
  sn=0
else
  speed=`echo "$ss $synctime"|awk '{print($1/$2)}'`
fi

echo $n2>$filenumber
if [ $n2 -eq 0 ];then
  s2=0
  synctime=0
fi
echo $s2>$filesize

if [ -f $srcsize ]; then 
  srcs=$(cat $srcsize|awk '{print $3}')
  srcday=$(cat $srcsize|awk '{print $1}')
  srctime=$(cat $srcsize|awk '{print $2}')
else
  srcs=0
  srcday=$today
  srctime=$ctime2
fi

if [ -z $srcs ];then
  srcs=0
fi

if [ -f $srcnumber ]; then
  srcn=$(cat $srcnumber|awk '{print $3}')
#  srcday=$(cat $srcnumber|awk '{print $1}')
#  srctime=$(cat $srcnumber|awk '{print $2}')
else
  srcn=0
  srcday=$today
  srctime=$ctime2
fi
if [ -z $srcn ];then
  srcn=0
fi

ctime4=`date  +%H:%M:%S`
#st2=`echo $ctime4|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
tend=`date +%s`
tdiff=`echo "$tstart $tend"|awk '{print($2-$1)}'`
today1=`date +%Y%m%d`
echo "$today1 $ctime4: Succeeded in Syncing $datatype data @ $server1!"
echo "======================================================="
echo "$srcday $srctime: @ $server1             "
echo "       Source Dir: $srcdir"
echo "    Source Number: $srcn file(s)"
echo "      Source Data: $srcs MB "
echo "********************************************************"
echo "$today1 $ctime4: @ $targetdir          "
echo "           Synced: $sn file(s)"
echo "                 : $ss MB "
echo "   Sync Time Used: $synctime secs."
echo "         @  Speed: $speed MB/s"
echo "     Total Synced: $n2 File(s)"
echo "                 : $s2 MB"
echo "  Total Time Used: $tdiff secs."
echo "             From: $today0 $ctime"
echo "               To: $today1 $ctime4"
echo "========================================================="
rm -rf $lockfile
cd /home/chd/
exit 0
#else
#  echo "$today $ctime: $procName  is running..."
#  echo "              PID: $pid                    "
#  exit 0
#fi


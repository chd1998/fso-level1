#!/bin/bash
#author: chen dong @fso
#purposes: manually syncing TIO/HA data in specified year(eg., 2019...) from remoteip to local lustre storage via lftp
#usage:  ./fso-copy.sh year(4 digits) monthday(4 digits) datatype(TIO/HA)
#example: ./fso-copy.sh 2019 0428 HA
#changlog: 
#      	 20190420      	Release 0.1	first prototype release 0.1
#      	 20190421	Release 0.2	fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
#        20190423      	Release 0.3	fix errors
#	 20190426	Release 0.4	fix errors
#        20190428       Release 0.5 	add monthday to the src dir
#	                Release 0.6     datatype is an option now
#	 20190603	Release 0.7	using lftp instead of wget
#	 20190604	Release 0.8	add progress bar to lftp
#	 20190608	Release 0.9	fixed error in directory
#	 		Release 1.0     improve display info

#waiting pid taskname prompt
waiting() {
        local pid="$1"
        taskname="$2"
        procing "$3" &
        local tmppid="$!"
        wait $pid
        tput rc
        tput ed
	ctime=`date --date='0 days ago' +%H:%M:%S`
	today=`date --date='0 days ago' +%Y%m%d`
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
                today=`date --date='0 days ago' +%Y%m%d`
                ctime=`date --date='0 days ago' +%H:%M:%S`
                echo -ne  "$today $ctime: $1...   $j"
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

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`

if [ $# -ne 3 ]  ;then
  echo "Copy specified date TIO/HA data on remote host to /lustre/data mannually"
  echo "Usage: ./fso-copy.sh year(4 digits)  monthday(4 digits) datatype(TIO/HA)"
  echo "Example: ./fso-copy.sh 2019 0427 TIO"
  exit 1
fi

procName="lftp"
syssep="/"
destpre0="/lustre/data"
ftpserver="ftp://192.168.111.120"
remoteport="21"
srcyear=$1
srcmonthday=$2
datatype=$3
ftpuser=$(echo $datatype|tr '[A-Z]' '[a-z]')
password="ynao246135"

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
echo "                      fso-copy.sh                        "  
echo "                                                         "
echo "             Relase 1.0     20190608  23:33              "
echo " Copy the TiO/HA data from remote SSD to lustre manually "
echo "                                                         "
echo "========================================================="
echo " "
procCmd=`ps ef|grep -w $procName|grep -v grep|wc -l`
pid=$(ps x|grep -w $procName|grep -v grep|awk '{print $1}')
if [ $procCmd -le 0 ];then
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
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: Syncing $datatype data @ FSO..."
  echo "                   From: $srcdir "
  echo "                   To  : $destdir "
#  echo ""
#  read
  cd $destdir
  ctimes=`date --date='0 days ago' +%H:%M:%S`
  #wget --tries=3 --timestamping --retry-connrefused --timeout=10 --continue --inet4-only --ftp-user=$ftpuser --ftp-password=ynao246135 --no-host-directories --recursive  --level=0 --no-passive-ftp --no-glob $srcdir
  #lftp -u $ftpuser,$password -e "mirror  --no-perms --only-missing --parallel=33 . $destdir; quit" $srcdir
  lftp -u $ftpuser,$password -e "mirror  --no-perms --no-umask --allow-chown --allow-suid --only-missing --parallel=33 .  $destdir; quit" $srcdir >/dev/null 2>&1 &
  waiting "$!" "$datatype Syncing" "Syncing $datatype Data"
  #echo "Please Wait..."
  ctime1=`date --date='0 days ago' +%H:%M:%S`
    if [ $? -ne 0 ];then
      echo "$today $ctime1: Failed in Syncing $datatype Data from $srcdir to $destdir"
      cd /home/chd
      exit 1
    fi

  t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`


  targetdir=${destdir}

  ls -lR $targetdir | grep "^-" | wc -l > tmpfn.dat &
  waiting "$!" "File Number Sumerizing" "Sumerizing File Number"
  if [ $? -ne 0 ];then
    ctime3=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime3: Sumerizing File Number of $datatype Failed!"
    cd /home/chd/
    exit 1
  fi
  filenumber=$(cat tmpfn.dat)

  du -sh $targetdir > tmpfs.dat &
  waiting "$!" "File Size Summerizing" "Sumerizing File Size"
  if [ $? -ne 0 ];then
    ctime3=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime3: Sumerizing File Size of $datatype Failed!"
    cd /home/chd/
    exit 1
  fi  
  filesize=$(cat tmpfs.dat)

  chmod 777 -R $destdir &
  waiting "$!" "Permission Changing" "Changing Permission"
  if [ $? -ne 0 ];then
    ctime3=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime3: Sumerizing File Number of $datatype Failed!"
    cd /home/chd/
    exit 1
  fi
  
  timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
  if [ $timediff -eq 0 ]; then
    speed=0
  else
    speed=`echo "$filesize $timediff"|awk '{print($1/$2)}'`
  fi  

  ctime2=`date --date='0 days ago' +%H:%M:%S`
  #chmod 777 -R $destdir
  echo " " 
  echo "$today $ctime2: Succeeded in Syncing $datatype data @ FSO!"
  echo "Synced file No.  : $filenumber"
  echo "Synced data size : $filesize"
  echo "           Speed : $speed MB/s"
  echo "       Time Used : $timediff secs."
  echo "       Time From : $ctimes "
  echo "              To : $ctime2 "

  rm -rf $lockfile
  cd /home/chd/
  exit 0
else
  echo "$today $ctime: $procName  is running..."
  echo "              PID: $pid                    "
  exit 0
fi


#!/bin/bash
#author: chen dong @fso
#changlog:
#        20190723       Release 0.1   first prototype release 0.1

#waiting pid taskname prompt
waiting() {
  local pid="$1"
  taskname="$2"
  procing "$3" &
  local tmppid="$!"
  wait $pid
#  tput rc
#  tput ed
  ctime=`date --date='0 days ago' +%H:%M:%S`
  today=`date --date='0 days ago' +%Y%m%d`
  echo "$today $ctime: $2 Task Has Done!"
  kill -6 $tmppid >/dev/null 1>&2
}

procing() {
  trap 'exit 0;' 6
  tput ed
  while [ 1 ]
  do
#    for j in '-' '\\' '|' '/'
#    do
#    tput sc
    ptoday=`date --date='0 days ago' +%Y%m%d`
    pctime=`date --date='0 days ago' +%H:%M:%S`
    echo "$ptoday $pctime: $1, please wait... "
    sleep 1
#    tput rc
#    done
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

if [ $# -ne 8 ]  ;then
	echo "Copy file of wrong size TIO/HA data on remote host to dest mannually"
	echo "Usage: ./fso-copy-wget-error-xx.sh srcip port user passwd loacaldrive error-file-list datatype stdsize"
	echo "Example: ./fso-copy-wget-error-xx.sh ftp://192.168.111.120 21 tio ynao246135 e /home/chd/log/error.list TIO 11062080"
	echo "Example: ./fso-copy-wget-error-xx.sh ftp://192.168.111.122 21 ha ynao246135 f /home/chd/log/error.list HA 2111040"
	exit 1
fi

#procName="lftp"
syssep="/"
destpre="/cygdrive"

#tmpfn=/home/chd/log/$(basename $0)-$errorlist-tmpfn.dat
#tmpfs=/home/chd/log/$(basename $0)-$errorlist-tmpfs.dat
#remotefile=/home/chd/log/$(basename $0)-$errorlist-remote.list
#errordir=/home/chd/log/$(basename $0)-$errorlist-dir.list
#errorfile=/home/chd/log/$(basename $0)-$errorlist-file.list

ftpserver=$1
remoteport=$2
ftpuser=$3
password=$4
localdrive=$5
errlist=$6
datatype=$7
stdsize=$8

homepre="/home/chd"
logpath=$homepre/log

if [ ! -f $errlist ];then 
  echo "$errlist is not exist, please check ..."
  exit 1
fi

lockfile=$logpath/$(basename $0)-$datatype-$today.lock
if [ -f $lockfile ];then
	mypid=$(cat $lockfile)
	ps -p $mypid | grep $mypid &>/dev/null
	if [ $? -eq 0 ];then
		echo "$todday $ctime: $(basename $0) is running..." && exit 1
	else
		echo $$>$lockfile
	fi
else
	echo $$>$lockfile
fi

echo " "
echo "======== Welcome to FSO Data Copying System@FSO! ========"
echo "                                                         "
echo "                 fso-copy-wget-error.sh                  "
echo "                                                         "
echo "             Relase 0.1     20190723  21:57              "
echo "          Copy the TiO/HA data file of wrong size        "
echo "                    from remote to local                 "
echo "                                                         "
echo "                $today    $ctime                         "
echo "                                                         "
echo "========================================================="
echo " "
#get path and file name of each error file
#cat $errorlist|awk '{print $1}'|cut -d '/' -f 4-10 > $remotefile
#touch ./localtmplist1
#for line in $(cat $remotefile);
#do
#  line=/$line
#  echo $line >> ./localtmplist1
#done
#mv ./localtmplist1 $remotefile

#cat $errorlist|awk '{print $1}'|cut -d '/' -f 1-9 > $errordir
#cat $errorlist|awk '{print $1}'|cut -d '/' -f 1-10 > $errorfile

ftpserver1=${ftpserver}:${remoteport}

count=0
size=0
starttime=`date --date='0 days ago' +%H:%M:%S`
t1=`date +%s`
echo "$today $starttime: Copying From $ftpserver1 "
echo "  "
#for each file in errlist
for line in $(cat $errlist);
do
	ctime=`date --date='0 days ago' +%H:%M:%S`
	rfile=$ftpserver1/$line
	localfile=$destpre/$localdrive/$line
	echo "$today $ctime: Copying $rfile"
	wget -O $localfile --ftp-user=$ftpuser --ftp-password=$password --no-passive-ftp  $rfile >/dev/null 2>&1 &
	waiting "$!" "$datatype file(s) in $errlist copying" "Copying $datatype $fileformat file(s) in $errlist"
	if [ $? -ne 0 ];then
		ctime1=`date --date='0 days ago' +%H:%M:%S`
		echo "$today $ctime1: Failed in Copying $rfile..."
		cd /home/chd
		exit 1
	else
	  tmps=`du -sm $localfile|awk '{print $1}'`
	  ctime1=`date --date='0 days ago' +%H:%M:%S`
	  if [ $tmps != $stdsize ]; then 
	    echo "$today $ctime1: Copying Failed for  $localfile $tmps MB"
	  else 
	    echo $localfile >localfile.tmp
        #remove corrected file from the list
	    #comm -3 --nocheck-order $errlist localfile.tmp > $errlist
		awk 'NR==FNR{ a[$1]=$1 } NR>FNR{ if(a[$1] == ""){ print $1}}' ./localfile.tmp $errlist > $errlist 
        #change the permission of copied file
	    #find $localfile ! -perm 777 -type f -exec chmod 777 {} \;
    	size=$((size+tmps))
	    echo "$today $ctime1: $localfile copied in $tmps MB"
	    ((count++))
	  fi
	fi  
done
endtime=`date --date='0 days ago' +%H:%M:%S`
#t1=`echo $starttime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#t2=`echo $endtime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t2=`date +%s`
timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
if [ $timediff -le 0 ]; then
	speed=0
else
	speed=`echo "$size $timediff"|awk '{print($1/$2)}'`
fi
errleft=`cat $errlist|wc -l`
ctime2=`date --date='0 days ago' +%H:%M:%S`
today0=`date --date='0 days ago' +%Y%m%d`
echo " "
echo "$today0 $ctime2: Succeeded in Data File(s) Error Correcting!"
echo "          Copied : $count file(s)"
echo "                 : $size MB"
echo "      Error Left : $errleft file(s)"
echo "           Speed : $speed MB/s"
echo "       Time Used : $timediff secs."
echo "            From : $today $starttime  "
echo "              To : $today0 $endtime "
rm -rf $lockfile
cd /home/chd/
exit 0

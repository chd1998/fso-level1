#!/bin/bash
#check the size of dest dir every 10 minutes via cron, and export total error list in file
#usage: ./fso-data-check-xx.sh /youdirhere/ datatype fileformat standardsize(in bytes)"
#example: ./fso-data-check-xx.sh /lustre/data/tmp/ TIO fits 11062080"
#example: ./fso-data-check-xx.sh /lustre/data/tmp/ HA fits 2111040"
#press ctrl-c to break the script
#change log:
#           Release 20190721-0931: First working prototype

trap 'onCtrlC' INT
function onCtrlC(){
		echo 'ctrl-c captured!'
		exit 1
}

waiting() {                                                                                                                                       
  local pid="$1"                                                                                                                                  
  taskname="$2"                                                                                                                                   
  procing "$3" &                                                                                                                                  
  local tmppid="$!"                                                                                                                               
  wait $pid                                                                                                                                       
  wctime=`date --date='0 days ago' +%H:%M:%S`                                                                                                     
  wtoday=`date --date='0 days ago' +%Y%m%d`                                                                                                       
                                                                                                                                                  
  echo "$wtoday $wctime: $2 Task Has Done!"                                                                                                       
  #dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  echo "                   Finishing...."                                                                                                         
  kill -6 $tmppid >/dev/null 1>&2                                                                                                                 
  #echo "$dt1" > /home/chd/log/$(basename $0)-$datatype-sdtmp.dat                                                                                  
}                                                                                                                                                 
                                                                                                                                                  
procing() {                                                                                                                                       
  trap 'exit 0;' 6                                                                                                                                
  tput ed                                                                                                                                         
  while [ 1 ]                                                                                                                                     
  do                                                                                                                                              
    sleep 1                                                                                                                                       
    ptoday=`date --date='0 days ago' +%Y%m%d`                                                                                                     
    pctime=`date --date='0 days ago' +%H:%M:%S`                                                                                                   
    echo "$ptoday $pctime: $1, Please Wait...   "                                                                                                 
  done                                                                                                                                            
}                                                                                                                                                 




if [ $# -ne 4 ];then
  echo "usage: ./fso-data-check-cron-cyg.sh /youdirhere/ datatype fileformat standardsize(in bytes)"
  echo "example: ./fso-data-check-cron-cyg.sh /f/20190721/TIO TIO fits 11062080"
  echo "example: ./fso-data-check-cron-cyg.sh /e/20190721/HA HA fits 2111040"
  exit 0
fi

#cd /home/chd/
homepre="/cygdrive/d/chd/LFTP4WIN-master/home/chd"
dirpre="/cygdrive"
syssep="/"
logpath=$homepre/log

today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
cdir=$dirpre$1
datatype=$2
fileformat=$3
stdsize=$4

list=$logpath/$datatype-$fileformat-$today.list
listtmp=$logpath/$datatype-$fileformat-$today-tmp.list
difflist=$logpath/$datatype-$fileformat-$today-diff.list
fn=$logpath/$datatype-$fileformat-$today-number.dat
curerrorlist=$logpath/size-error-of-$datatype-$fileformat@$today-cur.list
totalerrorlist=$logpath/size-error-of-$datatype-$fileformat@$today-total.list

lockfile=$logpath/$(basename $0)-$datatype.lock
                                                                                   
if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    echo "$today $ctime: $(basename $0) is running for checking $datatype file(s) size..." 
    exit 1
  else
    echo $$>$lockfile
  fi
else
  echo $$>$lockfile
fi                                                                                  

if [ ! -d "$logpath" ];then
  mkdir -p $logpath
fi

if [ ! -f "$list" ];then
  touch $list
fi



if [ ! -d "$cdir" ];then
  echo "Dest Dir: $cdir doesn't exist...."
  echo "Please check..."
  exit 0
fi
ctime=`date --date='0 days ago' +%H:%M:%S`
t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
echo " "
echo "================================================================================"
echo "                                                                                "
echo "               fso-data-check utility for $datatype data @ fso                  "
echo "                       Release 20190721-0931                                    "
echo "                                                                                "
echo "$today $ctime : Checking the $fileformat file numbers & size                    "
echo "                    @ $cdir                                                     "
echo "                    Please wait...                                              "
echo "                    Press ctrl-c to break!                                      "
echo "                                                                                "
echo "================================================================================"
echo " "
cd $cdir
#getting file number
find . -type f -name '*.fits'  |wc -l > $fn &
waiting "$!" "$datatype $fileformat file(s) number getting" "Getting $datatype $fileformat file(s) number"
#getting file name & size
find $cdir/ -type f -name '*.fits' -printf "%h/%f %s\n" > $listtmp &
waiting "$!" "$datatype $fileformat file(s) info getting" "Getting $datatype $fileformat file(s) info"
#remove checked files
grep -vwf $list $listtmp > $difflist &
waiting "$!" "new $datatype $fileformat file(s) getting" "Getting  new $datatype $fileformat file(s) "
#count error number for this round
cat $difflist |awk '{ if ($2!='''$stdsize''') {print $1"  "$2}}' > $curerrorlist &
waiting "$!" "Wrong $datatype $fileformat file(s) checking" "Checking wrong $datatype $fileformat file(s)"
curerror=`cat $curerrorlist|wc -l`
#check new files
#cat $difflist |awk '{ if ($2!='''$stdsize''') {print $1"  "$2}}' >> $totalerrorlist &
cat $curerrorlist >> $totalerrorlist &
waiting "$!" "Wrong $datatype $fileformat file(s) checking round #2" "Checking wrong $datatype $fileformat file(s) for round #2"
totalerror=`cat $totalerrorlist|wc -l`
mv -f $listtmp $list
curnum=$(cat $fn)
today=`date --date='0 days ago' +%Y%m%d`
ctime1=`date --date='0 days ago' +%H:%M:%S`
t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
if [ $timediff -lt 0 ]; then
	timediff=0
fi
echo "$today $ctime1: For $datatype $fileformat Data File(s) @ $cdir "
echo "     File Checked: $curnum file(s)"
echo " This Round Found: $curerror file(s) in wrong size"
echo "      Total Found: $totalerror file(s) in wrong size"
echo "        Time Used: $timediff secs."
echo "  Error File List: $totalerrorlist"
echo " "
echo "================================================================================"

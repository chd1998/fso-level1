#!/bin/bash
#check the size of dest dir every 10 minutes via cron, and export total error list in file
#usage: ./fso-data-check-remote-cron.sh ip port user passwd year monthday datatype fileformat"
#example: ./fso-data-check-remote-cron.sh 192.168.111.120 21 tio ynao246135 2019 0907 TIO fits"
#example: ./fso-data-check-remote-cron.sh 192.168.111.122 21 ha ynao246135 2019 0907 HA fits"
#press ctrl-c to break the script
#change log:
#           Release 0.1.0: First working prototype
#           Release 0.1.1: Revised remote & local file lists comparison
#           Release 0.1.2: Using comm -23 for file lists comparison

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
  wctime=`date  +%H:%M:%S`                                                                                                     
  wtoday=`date  +%Y%m%d`                                                                                                       
                                                                                                                                                  
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
    ptoday=`date  +%Y%m%d`                                                                                                     
    pctime=`date  +%H:%M:%S`                                                                                                   
    echo "$ptoday $pctime: $1, Please Wait...   "                                                                                                 
  done                                                                                                                                            
}                                                                                                                                                 




if [ $# -ne 8 ];then
  echo "usage: ./fso-data-check-remote-cron.sh ip port user passwd datatype year monthday fileformat"
  echo "example: ./fso-data-check-remote-cron.sh 192.168.111.120 21 tio ynao246135 2019 0907 TIO fits"
  echo "example: ./fso-data-check-remote-cron.sh 192.168.111.122 21 ha ynao246135 2019 0907 HA fits"
  exit 1
fi

today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`

server=$1
port=$2
user=$3
passwd=$4
year=$5
monthday=$6
datatype=$7
fileformat=$8

#cd /home/chd/
homepre="/home/chd"
syssep="/"
logpath=$homepre/log
localpre="/lustre/data"

remotelist=$logpath/$datatype-$fileformat-$year$monthday-$server.list
locallist=$logpath/$datatype-$fileformat-$year$monthday-local.list
difflist=$logpath/$datatype-$fileformat-$year$monthday-diff.list

lockfile=$logpath/$(basename $0)-$datatype-$monthday.lock
                                                                                   
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

#if [ ! -f "$list" ];then
#  touch $list
#fi

localdir=$localpre/$year/$year$monthday/$datatype
remotedir=/$year$monthday/$datatype

ctime=`date  +%H:%M:%S`
if [ ! -d $localdir ];then
  echo "$today $ctime : $localdir isn't exist!"
  exit 1
fi

pver=0.1.2

ctime=`date  +%H:%M:%S`
t1=`date +%s`
#t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
echo " "
echo "================================================================================"
echo "                                                                                "
echo "               fso-data-check for remote and local files                        "
echo "                       Release $pver(for Cron)                          "
echo "                                                                                "
echo "$today $ctime : Checking the $fileformat file between $server & local           "
echo "                    Please wait...                                              "
echo "                    Press ctrl-c to break!                                      "
echo "                                                                                "
echo "================================================================================"
echo " "
#cd $cdir
#getting local file list
#find $localdir/ -type f -name '*.fits' -type f ! -name "*level*"  |cut -d '/' -f 5-11> $locallist &
find $localdir/ -type f -name '*.fits' -not -path "*redata*"  |cut -d '/' -f 5-11> $locallist & 
waiting "$!" "local $datatype $fileformat file(s) info getting" "Getting local $datatype $fileformat file(s) info"

#getting remote file list
#cat $listtmp |wc -l > $fn &
#waiting "$!" "$datatype $fileformat file(s) number getting" "Getting $datatype $fileformat file(s) number"
server1=ftp://$user:$passwd@$server
#echo $server1
lftp $server1 -e "find $remotedir;quit"| grep $fileformat|cut -d '/' -f 1-9 > $remotelist &
waiting "$!" "remote $datatype $fileformat file(s) info getting" "Getting remote $datatype $fileformat file(s) info"
#add / to locallist
touch ./localtmplist
for line in $(cat $locallist);
do
  line=/$line
  echo $line >> ./localtmplist
done
mv ./localtmplist $locallist

#sort filelist
#sort $locallist -o $locallist
#sort $remotelist -o $remotelist

#getting local missing file(s) list
#grep -vwf $remotelist $locallist > $difflist &
#comm -23 --nocheck-order $remotelist $locallist | uniq > $difflist &
awk 'NR==FNR{ a[$1]=$1 } NR>FNR{ if(a[$1] == ""){ print $1}}'  $locallist $remotelist  > $difflist &
waiting "$!" "diff $datatype $fileformat file(s) getting" "Getting diff new $datatype $fileformat file(s) "

totalnum=$(cat $remotelist|wc -l)
diffnum=$(cat $difflist|wc -l)

today=`date  +%Y%m%d`
ctime1=`date  +%H:%M:%S`
t2=`date +%s`
#t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
if [ $timediff -lt 0 ]; then
	timediff=0
fi
echo "$today $ctime1: For $datatype $fileformat Data File(s) @ $cdir "
echo "     File Checked: $totalnum file(s) @ $server"
echo "      Total Found: $diffnum file(s) missing in local dir"
echo "        Time Used: $timediff secs."
echo "Missing File List: $difflist"
echo " "
echo "================================================================================"

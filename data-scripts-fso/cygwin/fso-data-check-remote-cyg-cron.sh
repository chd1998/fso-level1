#!/bin/bash
#check the file diff between remote dir  and local dir, export the diff list file
#usage: ./fso-data-check-remote-cyg-cron.sh ip port user passwd year monthday datatype fileformat localdrive"
#example: ./fso-data-check-remote-cyg-cron.sh 192.168.111.120 21 tio ynao246135 2019 0907 fits e"
#example: ./fso-data-check-remote-cyg-cron.sh 192.168.111.122 21 ha ynao246135 2019 0907 fits f"
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




if [ $# -ne 8 ];then
  echo "usage: ./fso-data-check-remote-cyg-cron.sh ip port user passwd  year monthday datatype fileformat localdrive"
  echo "example: ./fso-data-check-remote-cyg-cron.sh 192.168.111.120 21 tio ynao246135 2019 0907 fits e"
  echo "example: ./fso-data-check-remote-cyg-cron.sh 192.168.111.122 21 ha ynao246135 2019 0907 fits f "
  exit 0
fi

today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`

server=$1
port=$2
user=$3
passwd=$4
year=$5
monthday=$6
fileformat=$7
localdrive=$8
datatype=`echo $user|tr 'a-z' 'A-Z'`

#cd /home/chd/
homepre="/home/chd"
syssep="/"
logpath=$homepre/log
localpre="/cygdrive"
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`


remotelist=$logpath/$datatype-$fileformat-$year$monthday-$server-cyg.list
locallist=$logpath/$datatype-$fileformat-$year$monthday-local-cyg.list
difflist=$logpath/$datatype-$fileformat-$year$monthday-diff-cyg.list

lockfile=$logpath/$(basename $0)-$datatype-$cyear$today.lock
                                                                                   
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

localdir=$localpre/$localdrive/$year$monthday/$datatype
if [ $datatype == "SP" ];then 
  remotedir=/$year$monthday/
else
  remotedir=/$year$monthday/$datatype
fi

ctime=`date --date='0 days ago' +%H:%M:%S`
#t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t1=`date +%s`
echo " "
echo "================================================================================"
echo "                                                                                "
echo "               fso-data-check for remote and local files                        "
echo "                       Release 20190908-1435(for Cron)                          "
echo "                                                                                "
echo "$today $ctime : Checking the $fileformat file between $server & local           "
echo "                    Please wait...                                              "
echo "                    Press ctrl-c to break!                                      "
echo "                                                                                "
echo "================================================================================"
echo " "
#cd $cdir

#getting local file list
if [ ! -d "$localdir" ];then
  echo "$today $ctime : local directory $localdir doesn't exist, pls check ..."
  exit 0
else
  find $localdir -type f -name '*.fits' |cut -d '/' -f 4-11> $locallist &
  waiting "$!" "local $datatype $fileformat file(s) info getting" "Getting local $datatype $fileformat file(s) info"
fi

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

#remove synced files, list is error files list, listtmp is all files
#grep -vwf $list $listtmp > $difflist &
#show files only in remote
#comm -23  $remotelist $locallist > $difflist &
awk 'NR==FNR{ a[$1]=$1 } NR>FNR{ if(a[$1] == ""){ print $1}}'  $locallist $remotelist > $difflist &
waiting "$!" "diff $datatype $fileformat file(s) getting" "Getting diff new $datatype $fileformat file(s) "

totalnum=$(cat $remotelist|wc -l)
diffnum=$(cat $difflist|wc -l)

today=`date --date='0 days ago' +%Y%m%d`
ctime1=`date --date='0 days ago' +%H:%M:%S`
#t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t2=`date +%s`
timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
if [ $timediff -lt 0 ]; then
	timediff=0
fi
today0=`date --date='0 days ago' +%Y%m%d`
echo "$today0 $ctime1: For $datatype $fileformat Data File(s) @ $cdir "
echo "     File Checked: $totalnum file(s) @ $server"
echo "      Total Found: $diffnum file(s) missing in local dir"
echo "        Time Used: $timediff secs."
echo "Missing File List: $difflist"
echo " "
echo "================================================================================"

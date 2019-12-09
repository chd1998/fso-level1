#!/bin/bash
#check the size of file(s) in dest dir and export total error list in file
#usage: ./fso-data-check-local-cyg-cron.sh /youdir year monthday datatype fileformat standardsize(in bytes)
#example: ./fso-data-check-local-cyg-cron.sh e 2019 0915 TIO fits 11062080
#example: ./fso-data-check-local-cyg-cron.sh f 2019 0915 HA fits 2111040
#example: ./fso-data-check-local-cyg-cron.sh g 2019 0721 SP fits 5359680
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
  #echo "$dt1" > /cygdrive/d/chd/LFTP4WIN-master/home/chd/log/$(basename $0)-$datatype-sdtmp.dat                                                                                  
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




if [ $# -ne 6 ];then
  echo "#usage: ./fso-data-check-local-cyg-cron.sh /youdir year monthday datatype fileformat standardsize(in bytes)"
  echo "example: ./fso-data-check-local-cyg-cron.sh e 2019 0915 TIO fits 11062080"
  echo "example: ./fso-data-check-local-cyg-cron.sh f 2019 0915 HA fits 2111040"
  echo "example: ./fso-data-check-local-cyg-cron.sh g 2019 0915 SP fits 5359680"
  exit 0
fi

#cd /home/chd/
homepre="/home/chd"
dirpre="/cygdrive"
syssep="/"
logpath=$homepre/log

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`

destpre=$dirpre/$1
year=$2
monthday=$3
datatype=$4
fileformat=$5
stdsize=$6
if [ $datatype == "SP" ];then
  stdsize1="1342080"
fi
cdir=$destpre/$year$monthday/$datatype

list=$logpath/$datatype-$fileformat-$year$monthday-local.list
listtmp=$logpath/$datatype-$fileformat-$year$monthday-local-tmp.list
difflist=$logpath/$datatype-$fileformat-$year$monthday-diff-cyg.list
fn=$logpath/$datatype-$fileformat-$year$monthday-number.dat
curerrorlist=$logpath/$datatype-$fileformat-$year$monthday-error-cur.list
totalerrorlist=$logpath/$datatype-$fileformat-$year$monthday-error-total.list
localwrongsize=$logpath/$datatype-local-wrongsize-$year$monthday-cyg.list

lockfile=$logpath/$(basename $0)-$datatype-$today.lock
                                                                                   
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
t1=`date +%s`
#t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
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
#cd $cdir

#getting file name & size
find $cdir/ -type f -name '*.fits' -printf "%h/%f %s\n" > $listtmp &
waiting "$!" "local $datatype $fileformat file(s) info getting" "Getting local $datatype $fileformat file(s) info"
#cat $listtmp|wc -l
#getting file number
#cat $listtmp  |wc -l > $fn &
#waiting "$!" "$datatype $fileformat file(s) number getting" "Getting $datatype $fileformat file(s) number"

#sort file lists
#sort $listtmp -o $listtmp
#sort $list -o $list

#remove checked files
#show only new file in listtmp to difflist
#comm -23 --nocheck-order $listtmp $list > $difflist &
#comm -23 $listtmp $list > $difflist &
#listtmp-list to get only in listtmp
awk 'NR==FNR{ a[$1]=$1 } NR>FNR{ if(a[$1] == ""){ print $1}}' $list $listtmp > $difflist &
waiting "$!" "new $datatype $fileformat file(s) getting" "Getting  new $datatype $fileformat file(s) "

#count error number for this round
if [ $datatype == "SP" ];then
  cat $difflist |awk '{ if ($2!='''$stdsize''' && $2!='''$stdsize1''') {print $1"  "$2}}' > $curerrorlist &
  waiting "$!" "Wrong $datatype $fileformat file(s) checking" "Checking wrong $datatype $fileformat file(s)"
else
  cat $difflist |awk '{ if ($2!='''$stdsize''') {print $1"  "$2}}' > $curerrorlist &
  waiting "$!" "Wrong $datatype $fileformat file(s) checking" "Checking wrong $datatype $fileformat file(s)"
fi

curerror=`cat $curerrorlist|wc -l`

#check new files
if [ ! -f $totalerrorlist ]; then 
  cp -f $curerrorlist $totalerrorlist
fi
#comm -23 $curerrorlist $totalerrorlist > ./curtmp &
# get new files in curerrorlist
awk 'NR==FNR{ a[$1]=$1 } NR>FNR{ if(a[$1] == ""){ print $1}}' $totalerrorlist $curerrorlist > ./curtmp &
waiting "$!" "New current wrong $datatype $fileformat file(s) finding" "Finding new current wrong $datatype $fileformat file(s)"
cat ./curtmp >> $totalerrorlist &
waiting "$!" "Current wrong $datatype $fileformat file(s) adding" "Adding current wrong $datatype $fileformat file(s)"

cat $totalerrorlist|awk '{print $1}' > $localwrongsize & 
waiting "$!" "Wrong $datatype $fileformat files list generating" "Generating  wrong $datatype $fileformat file(s)"

#add / to locallist
touch ./localtmplist
for line in $(cat $localwrongsize);
do
  if [[ $line != /* ]]; then
  line=/$line
  fi
  echo $line >> ./localtmplist
done
mv ./localtmplist $localwrongsize

totalerror=`cat $totalerrorlist|wc -l`
mv -f $listtmp $list
curnum=$(cat $difflist|wc -l)
today=`date --date='0 days ago' +%Y%m%d`
ctime1=`date --date='0 days ago' +%H:%M:%S`
t2=`date +%s`
#t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
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
rm -f ./curtmp
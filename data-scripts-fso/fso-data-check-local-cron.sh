#!/bin/bash
#check the size of dest dir every 10 minutes via cron, and export total error list in file
#usage: ./fso-data-check-xx.sh /youdirpre year monthday datatype fileformat standardsize(in bytes)
#example: ./fso-data-check-local-cron.sh /lustre/data/ 2019 0913 TIO fits 11062080
#example: ./fso-data-check-local-cron.sh /lustre/data/ 2019 0913 SP  fits 5359680
#example: ./fso-data-check-local-cron.sh /lustre/data/ 2019 0913 HA fits 2111040
#press ctrl-c to break the script
#change log:
#           Release 20190721-0931: First working prototype
#           Release 20190915-0835: Revised file(s) lists comparison

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

if [ $# -ne 6 ];then
  echo "usage: ./fso-data-check-xx.sh /youdirpre year monthday datatype fileformat standardsize(in bytes)"
  echo "example: ./fso-data-check-local-cron.sh /lustre/data 2019 0913 TIO fits 11062080"
  echo "example: ./fso-data-check-local-cron.sh /lustre/data 2019 0913 SP  fits 5359680"
  echo "example: ./fso-data-check-local-cron.sh /lustre/data 2019 0913 HA fits 2111040"
  exit 0
fi

today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`

destpre=$1
year=$2
monthday=$3
datatype=$4
fileformat=$5
stdsize=$6
if [ $datatype == "SP" ];then
  stdsize1="1342080"
fi
cdir=$destpre/$year/$year$monthday


#cd /home/chd/
homepre="/home/chd"
syssep="/"
logpath=$homepre/log

list=$logpath/$datatype-$fileformat-$year$monthday.list
listtmp=$logpath/$datatype-$fileformat-$year$monthday-tmp.list
difflist=$logpath/$datatype-$fileformat-$year$monthday-diff.list
fn=$logpath/$datatype-$fileformat-$year$monthday-number.dat
curerrorlist=$logpath/$datatype-$fileformat-$year$monthday-error-cur.list
totalerrorlist=$logpath/$datatype-$fileformat-$year$monthday-error-total.list
localwrongsize=$logpath/$datatype-local-wrongsize-$year$monthday.list

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

if [ ! -d $logpath ];then
  mkdir -p $logpath
fi

if [ ! -f $list ];then
  touch $list
fi



if [ ! -d $cdir ];then
  echo "Dest Dir: $cdir doesn't exist...."
  echo "Please check..."
  exit 0
fi
ctime=`date --date='0 days ago' +%H:%M:%S`
#t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t1=`date +%s`
echo " "
echo "================================================================================"
echo "                                                                                "
echo "               fso-data-check utility for $datatype data @ fso                  "
echo "                       Release 20190915-0835(for Cron)                          "
echo "                                                                                "
echo "$today $ctime : Checking the $fileformat file numbers & size                    "
echo "                    @ $cdir/$datatype/                                          "
echo "                    Please wait...                                              "
echo "                    Press ctrl-c to break!                                      "
echo "                                                                                "
echo "================================================================================"
echo " "
#cd $cdir
#getting file name & size
find $cdir/$datatype/ -type f -name '*.fits' -printf "%h/%f %s\n" > $listtmp &
waiting "$!" "local $datatype $fileformat file(s) info getting" "Getting  local $datatype $fileformat file(s) info"

#getting file number
#cat $listtmp |wc -l > $fn &
#waiting "$!" "$datatype $fileformat file(s) number getting" "Getting $datatype $fileformat file(s) number"

<<<<<<< HEAD
#remove checked files, list is error files list, listtmp is all files
=======
#remove checked files, list is files list from previous, listtmp is all files for this run
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
#sort $listtmp -o $listtmp
#sort $list -o $list

#grep -vwf $listtmp $list > $difflist &
#show only new file in listtmp
#comm -23 --nocheck-order $listtmp $list > $difflist &
awk 'NR==FNR{ a[$1]=$1 } NR>FNR{ if(a[$1] == ""){ print $1}}' $list $listtmp> $difflist &
waiting "$!" "new $datatype $fileformat file(s) getting" "Getting  new $datatype $fileformat file(s) "

#count error number for this round
ctime0=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime0: Checking local wrong size $datatype files, please waiting..."
#cat $difflist |awk '{ if ($2!='''$stdsize''') {print $1"  "$2}}' > $curerrorlist &
if [ $datatype == "SP" ];then
  cat $difflist |awk '{ if ($2!='''$stdsize''' && $2!='''$stdsize1''') {print $1"  "$2}}' > $curerrorlist &
  waiting "$!" "Wrong $datatype $fileformat file(s) checking" "Checking wrong $datatype $fileformat file(s)"
else
#  if [ $datatype == "HA" || $datatype == "TIO" ];then
   cat $difflist |awk '{ if ($2!='''$stdsize''') {print $1"  "$2}}' > $curerrorlist &
   waiting "$!" "Wrong $datatype $fileformat file(s) checking" "Checking wrong $datatype $fileformat file(s)"
#  else
#    echo "$today $ctime0 : Wrong $datatype inputed, please check..."
#    touch $curerrorlist
#  fi
fi
#waiting "$!" "Wrong $datatype $fileformat file(s) checking" "Checking wrong $datatype $fileformat file(s)"
curerror=`cat $curerrorlist|wc -l`

#add wrongsize list to total error list

#show only new files in curerrorlist
if [ ! -f "$totalerrorlist" ];then
  if [ $datatype == "SP" ];then
    cat $difflist |awk '{ if ($2!='''$stdsize''' && $2!='''$stdsize1''') {print $1"  "$2}}' > $totalerrorlist &
  else
    cat $difflist |awk '{ if ($2!='''$stdsize''') {print $1"  "$2}}' >> $totalerrorlist &
  fi
  waiting "$!" "Total error $datatype $fileformat file(s) list finding  --- first round" "Finding new error $datatype $fileformat file(s) to total error file(s) list for first round"
fi

#sort $totalerrorlist -o $totalerrorlist
<<<<<<< HEAD
#comm -23 --nocheck-order $curerrorlist $totalerrorlist > ./errtmp &
#get files only in curerrorlist
awk 'NR==FNR{ a[$1]=$1 } NR>FNR{ if(a[$1] == ""){ print $1}}' $totalerrorlist $curerrorlist > ./errtmp &
waiting "$!" "New current error $datatype $fileformat file(s) list finding" "Finding new error $datatype $fileformat file(s) to total error file(s) list"
cat ./errtmp >> $totalerrorlist &
=======
#comm -23 --nocheck-order $curerrorlist $totalerrorlist > $logpath/errtmp-check-local-$monthday &
#get files only in curerrorlist
awk 'NR==FNR{ a[$1]=$1 } NR>FNR{ if(a[$1] == ""){ print $1}}' $totalerrorlist $curerrorlist > $logpath/errtmp-check-local-$monthday &
waiting "$!" "New current error $datatype $fileformat file(s) list finding" "Finding new error $datatype $fileformat file(s) to total error file(s) list"
cat $logpath/errtmp-check-local-$monthday >> $totalerrorlist &
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
waiting "$!" "Current error $datatype $fileformat file(s) list adding" "Adding error $datatype $fileformat file(s) to total error file(s) list"

totalerror=`cat $totalerrorlist|wc -l`
#get 1st column of totalerrorlist , prepare for wget
cat $totalerrorlist|awk '{print $1}'|cut -d '/' -f 5-11 > $localwrongsize
#add / to each line in 1st column
touch ./mytmplist
for line in $(cat $localwrongsize);
do
  if [[ $line != /* ]]; then
  line=/$line
  fi
  echo $line >> ./mytmplist
done
mv -f ./mytmplist $localwrongsize

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
echo "  Error File List: $localwrongsize"
echo " "
echo "================================================================================"
#rm -f ./mytmplist
<<<<<<< HEAD
rm -f ./errtmp
=======
rm -f $logpath/errtmp-check-local-$monthday
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0

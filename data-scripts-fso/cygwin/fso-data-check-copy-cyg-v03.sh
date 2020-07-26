#!/bin/sh
#author: chen dong @fso
#purposes: check the data & copy the wrong file(s) 
#Usage: ./fso-data-check-copy-cron-cyg.sh ip port  localdrive user password datatype(TIO/HA/SP) fileformat stdsize
#Example: ./fso-data-check-copy-cron-cyg.sh  192.168.111.120 21 e tio ynao246135 2019 0918 fits 11062080
#Example: ./fso-data-check-copy-cron-cyg.sh  192.168.111.122 21 f ha ynao246135 2019 0918 fits 2111040
#Example: ./fso-data-check-copy-cron-cyg.sh  192.168.111.122 21 g sp ynao246135 2019 0918 fits 5359680
#changlog: 
#       20190725   Release 0.1     first working version.sh
#       20190914   Release 0.2     revised and add comparison of remote & local file(s)
#                  Release 0.3     add sp data check with 2 stdsize
#                  Release 0.31    add more info to output mail
#       20200420   Release 0.32    revised & add more info to output mail
# 

#waiting pid taskname prompt
waiting() {
  local pid="$1"
  taskname="$2"
  procing "$3" &
  local tmppid="$!"
  wait $pid

  wctime=`date  +%H:%M:%S`
	wtoday=`date  +%Y%m%d`
               
  echo "\n"
  echo "$wtoday $wctime: $2 Task Has Done!"
  #dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  echo "                   Finishing...."
  kill -6 $tmppid >/dev/null 1>&2
  #echo "$dt1" > $logpath/$(basename $0)-$datatype-sdtmp.dat
}

procing() {
  trap 'exit 0;' 6
  tput ed
  while [ 1 ]
  do
    tput sc
    tput ed
    for j in '-' '\\' '|' '/'
    do
      ptoday=`date  +%Y%m%d`
      pctime=`date  +%H:%M:%S`
      echo  -ne "$ptoday $pctime: $1, Please Wait...  $j "
      sleep 1
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
mday=`date  +%m%d`
ctime=`date  +%H:%M:%S`
syssep="/"

if [ $# -ne 9 ];then
  echo "Usage: ./fso-data-check-copy-cron-cyg.sh ip port  localdrive user password datatype(TIO/HA/SP) fileformat stdsize"
  echo "Example: ./fso-data-check-copy-cron-cyg.sh  192.168.111.120 21 e tio ynao246135 2019 0918 fits 11062080"
  echo "Example: ./fso-data-check-copy-cron-cyg.sh  192.168.111.122 21 f ha ynao246135  2019 0918 fits 2111040"
  echo "Example: ./fso-data-check-copy-cron-cyg.sh  192.168.111.122 21 g sp ynao246135 2019 0918 fits 5359680"
  exit 1
fi
server=$1
port=$2
localdrive=$3
destpre=/cygdrive/$3
user=$4
password=$5
year=$6
monthday=$7
fileformat=$8
stdsize=$9
datatype=`echo $user|tr -t 'a-z' 'A-Z'`

homepre="/home/chd"
logpath=$homepre/log

lockfile=$logpath/$(basename $0)-$datatype-$monthday.lock

if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    echo "$today $ctime: $(basename $0) is running for checking $datatype data..." &&  exit 1
  else
    echo $$>$lockfile
  fi
else
  echo $$>$lockfile
fi

remotelocaldifflist=$logpath/$datatype-$fileformat-$year$monthday-diff-cyg.list
localwrongsize=$logpath/$datatype-local-wrongsize-$year$monthday-cyg.list
#errlist=/cygdrive/d/chd/LFTP4WIN-master/home/chd/log/$datatype-$fileformat@$(date +\%Y\%m\%d)-error-total.list
tmplist=$logpath/$datatype-$fileformat-$year$monthday-tmp.list

totalfilenumberdat=$logpath/fso-copy-lftp-cyg-cron.sh_$datatype\_tmpfn2.dat
totalfilenumber=`cat $totalfilenumberdat | awk {'print $3'}`
if [[ $totalfilenumber -eq 0 ]];then
  totalfilenumber=0
fi

#touch $remotelocaldifflist
#touch $localwrongsize
#touch $tmplist

ctime1=`date  +%H:%M:%S`
#st1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
st1=`date +%s`
echo "                                                       "
echo "======= Welcome to Data Archiving System @ FSO! ======="
echo "              fso-data-check-copy.sh                   "
echo "          (Release 0.32 20200420 13:48)                "
echo "                                                       "
echo "              Check $datatype data and copy            "
echo "                                                       "
echo "                $today $ctime1                         "
echo "======================================================="
echo " "
echo "$today $ctime1: Testing $server is online or not, please wait..."
ping $server -c 5 | grep ttl >> $logpath/pingtmp
pingres=`cat $logpath/pingtmp | wc -l`
rm -f $logpath/pingtmp

ctime=`date  +%H:%M:%S`

if [ $pingres -ne 0 ];then 
  echo "$today $ctime: $server is online..."
  #echo "$today $ctime: Remote & Local $datatype File(s) Checking, please wait..."
  #remote local diff 
  echo "$today $ctime: Local Missing $datatype File(s) Checking, please wait..."
  #./fso-data-check-copy-cron.sh  192.168.111.120 21 e tio ynao246135 TIO fits 11062080
  #./fso-data-check-copy-cron.sh  192.168.111.122 21 f ha ynao246135 HA fits 2111040
  #./fso-data-check-copy-cron.sh  192.168.111.122 21 g sp ynao246135 SP fits 5359680
  ctime=`date  +%H:%M:%S`
  $homepre/fso-data-check-remote-cyg-cron.sh $server $port $user $password $year $monthday $fileformat $localdrive > $logpath/check-local-missing-$datatype-file.log &
  waiting "$!" "Local Missing $datatype File(s) Checking" "Checking Local Missing $datatype File(s)"
  errsize=`cat $remotelocaldifflist|wc -l`
  

  #copy local missing file
  ctime=`date  +%H:%M:%S`
  if [ $errsize -ne 0 ];then
    echo "$today $ctime: Local $datatype Wrong Size File(s) Copying, please wait..."
    $homepre/fso-copy-wget-error-cron-cyg.sh $server $port $user $password $localdrive $remotelocaldifflist $datatype $stdsize > $logpath/$datatype-missing-copy-$(date +\%Y\%m\%d).log &
    waiting "$!" "Local Missing $datatype  File(s) Copying" "Copying Local Missing $datatype  File(s)"
  fi
  errsize0=`cat $remotelocaldifflist|wc -l`
else
  errsize=0
  errsize0=$errsize
  echo "$today $ctime: $server is offline, skipping remote & local comparison..."
fi 

ctime=`date  +%H:%M:%S`
tmperrsize=`echo "$errsize0 $errsize"|awk '{print($2-$1)}'`
echo "$today $ctime: $tmperrsize local missing $datatype file(s) copied from remote"

#checking local files' size
ctime=`date  +%H:%M:%S`
echo "$today $ctime: Local $datatype File(s) Size Checking, please wait..."
$homepre/fso-data-check-local-cyg-cron.sh $localdrive $year $monthday $datatype $fileformat $stdsize > $logpath/check-local-$datatype-size.log &
waiting "$!" "Local $datatype File(s) Size Checking" "Checking Local $datatype File(s) Size"
errsize1=`cat $localwrongsize|wc -l`

ctime=`date  +%H:%M:%S`
if [ $pingres -ne 0 ];then 
  #copying local wrong size files from remote
  echo "$today $ctime: $datatype Wrong Size File(s) Copying, please wait..."
  $homepre/fso-copy-wget-error-cron-cyg.sh $server $port $user $password $localdrive $localwrongsize $datatype $stdsize > $logpath/$datatype-local-wrongsize-copy-$year$monthday.log &
  waiting "$!" "Local $datatype Wrong Size File(s) Copying" "Copying Local $datatype Wrong Size File(s)"
else
  echo "$today $citme: Skipping Copying Local Wrong Size $datatype File(s) from Remote..."
fi

errsize2=`cat $localwrongsize|wc -l`

#final corrected file(s) left
errsize3=`echo "$errsize0 $errsize2"|awk '{print($1+$2)}'`
#add total number of wrong file(s)
errsize4=`echo "$errsize $errsize1"|awk '{print($1+$2)}'`

ctime3=`date  +%H:%M:%S`

#$tmp1=`cat $remotelocaldifflist|wc -l`
#$tmp2=`cat $localwrongsize|wc -l`
cat $remotelocaldifflist > $tmplist
cat $localwrongsize >> $tmplist

ctime3=`date  +%H:%M:%S`
echo "                  For $year$monthday $datatype Data File(s)" > $logpath/errtmp-$year$monthday
echo "***********************************************************************************************************************" >> $logpath/errtmp-$year$monthday
echo "$today $ctime1 : Start $datatype File(s) Checking... " >> $logpath/errtmp-$year$monthday
echo "$today $ctime3 : $totalfilenumber $datatype File(s) Checked... " >> $logpath/errtmp-$year$monthday
echo "                " >> $logpath/errtmp-$year$monthday
echo "$today $ctime3 : $errsize0 Error $datatype File(s) in Local Missing File(s) Checking" >> $logpath/errtmp-$year$monthday
cat $remotelocaldifflist >> $logpath/errtmp-$year$monthday
echo "                " >> $logpath/errtmp-$year$monthday
echo "                    $errsize2 Error $datatype File(s) in Local Wrong Size File(s) Checking" >> $logpath/errtmp-$year$monthday
cat $localwrongsize >> $logpath/errtmp-$year$monthday


#cat $remotelocaldifflist $errlist > $tmplist 
errsize5=`cat $tmplist|wc -l`

ctime3=`date  +%H:%M:%S`
echo "$today $ctime3: Sending notification email to Observation Assistant..."
#sending email to observers
email -s "$year$monthday-$datatype@fso-data: $errsize5 Error $datatype File(s) Found" nvst_obs@ynao.ac.cn < $logpath/errtmp-$year$monthday
email -s "$year$monthday-$datatype@fso-data: $errsize5 Error $datatype File(s) Found" chd@ynao.ac.cn < $logpath/errtmp-$year$monthday

#echo "$today $ctime3: $errsize0 Error File(s) in Local Missing File(s) Checking:" > ./errtmp
#cat $remotelocaldifflist >> ./errtmp

#echo "                " >> ./errtmp
#echo "$today $ctime3:  $errsize2 Error File(s) in Local Wrong Size File(s) Checking:" >> ./errtmp
#cat $localwrongsize >> ./errtmp


#cat $remotelocaldifflist $errlist > $tmplist 
#errsize5=`cat $tmplist|wc -l`

#ctime3=`date  +%H:%M:%S`
#echo "$today $ctime3: Sending notification email to Observation Assistant..."
#sending email to observers
#email -s "$year$monthday-$datatype@fso-data: $errsize5 Error File(s) Found" nvst_obs@ynao.ac.cn < ./errtmp
#email -s "$year$monthday-$datatype@fso-data: $errsize5 Error File(s) Found" chd@ynao.ac.cn < ./errtmp



ctime4=`date  +%H:%M:%S`
today0=`date  +%Y%m%d`
#st2=`echo $ctime4|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
st2=`date +%s`
stdiff=`echo "$st1 $st2"|awk '{print($2-$1)}'`

echo "$today0 $ctime4: Checking & Copying $datatype data @ FSO finished!"
#echo "           Total : $errsize4 error file(s) found"
echo "                 : $errsize5 file(s) left"
echo "                 : see $tmplist for all file(s) details"
echo "                 : $errsize0 file(s) found in remote local comparison"
echo "                 : see $remotelocaldifflist for details "
echo "                 : $errsize2 file(s) found in local wrong size checking"
echo "                 : see $localwrongsize for details"
echo "       Time Used : $stdiff secs."
echo "            From : $today $ctime1"
echo "              To : $today0 $ctime4"
echo "================================================================================="
rm -rf $lockfile
rm -f $logpath/errtmp-$year$monthday





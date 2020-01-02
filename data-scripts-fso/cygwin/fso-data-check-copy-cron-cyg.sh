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
# 

#waiting pid taskname prompt
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
  #echo "$dt1" > $logpath/$(basename $0)-$datatype-sdtmp.dat
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

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    exit 1
}

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
mday=`date --date='0 days ago' +%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
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

<<<<<<< HEAD
lockfile=$logpath/$(basename $0)-$datatype-$monthday.lock
=======
<<<<<<< HEAD
lockfile=$logpath/$(basename $0)-$datatype-$cyear$today.lock
=======
lockfile=$logpath/$(basename $0)-$datatype-$monthday.lock
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402

if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
<<<<<<< HEAD
    echo "$today $ctime: $(basename $0) is running for checking $datatype data..." &&  exit 1
=======
<<<<<<< HEAD
    echo "$today $ctime: $(basename $0) is running for checking $datatype data..." 
    exit 1
=======
    echo "$today $ctime: $(basename $0) is running for checking $datatype data..." &&  exit 1
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
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

#touch $remotelocaldifflist
#touch $localwrongsize
#touch $tmplist

ctime1=`date --date='0 days ago' +%H:%M:%S`
#st1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
st1=`date +%s`
echo "                                                       "
echo "======= Welcome to Data Archiving System @ FSO! ======="
echo "              fso-data-check-copy.sh                   "
echo "          (Release 0.31 20191029 20:38)                "
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

ctime=`date --date='0 days ago' +%H:%M:%S`

if [ $pingres -ne 0 ];then 
  echo "$today $ctime: $server is online..."
  #echo "$today $ctime: Remote & Local $datatype File(s) Checking, please wait..."
  #remote local diff 
  echo "$today $ctime: Local Missing $datatype File(s) Checking, please wait..."
  #./fso-data-check-copy-cron.sh  192.168.111.120 21 e tio ynao246135 TIO fits 11062080
  #./fso-data-check-copy-cron.sh  192.168.111.122 21 f ha ynao246135 HA fits 2111040
  #./fso-data-check-copy-cron.sh  192.168.111.122 21 g sp ynao246135 SP fits 5359680
  ctime=`date --date='0 days ago' +%H:%M:%S`
  $homepre/fso-data-check-remote-cyg-cron.sh $server $port $user $password $year $monthday $fileformat $localdrive > $logpath/check-local-missing-$datatype-file.log &
  waiting "$!" "Local Missing $datatype File(s) Checking" "Checking Local Missing $datatype File(s)"
<<<<<<< HEAD
=======
<<<<<<< HEAD
  if [ $? -ne 0 ];then
    ctime3=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime3: Local Missing $datatype File(s) Size Check Failed!"
    #exit 1
  fi
=======
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
  errsize=`cat $remotelocaldifflist|wc -l`
  

  #copy local missing file
  ctime=`date --date='0 days ago' +%H:%M:%S`
  if [ $errsize -ne 0 ];then
<<<<<<< HEAD
    echo "$today $ctime: Local $datatype Missing File(s) Copying, please wait..."
    $homepre/fso-copy-wget-error-cron-cyg.sh $server $port $user $password $localdrive $remotelocaldifflist $datatype $stdsize > $logpath/$datatype-missing-copy-$(date +\%Y\%m\%d).log &
    waiting "$!" "Local Missing $datatype  File(s) Copying" "Copying Local Missing $datatype  File(s)"
=======
<<<<<<< HEAD
    echo "$today $ctime: Local $datatype Wrong Size File(s) Copying, please wait..."
    $homepre/fso-copy-wget-error-cron-cyg.sh $server $port $user $password $localdrive $remotelocaldifflist $stdsize > $logpath/$datatype-missing-copy-$(date +\%Y\%m\%d).log &
    waiting "$!" "Local Missing $datatype  File(s) Copying" "Copying Local Missing $datatype  File(s)"
    if [ $? -ne 0 ];then
      ctime3=`date --date='0 days ago' +%H:%M:%S`
      echo "$today $ctime3: Local $datatype Missing File(s) Copy Failed!"
      #exit 1
    fi
=======
    echo "$today $ctime: Local $datatype Missing File(s) Copying, please wait..."
    $homepre/fso-copy-wget-error-cron-cyg.sh $server $port $user $password $localdrive $remotelocaldifflist $datatype $stdsize > $logpath/$datatype-missing-copy-$(date +\%Y\%m\%d).log &
    waiting "$!" "Local Missing $datatype  File(s) Copying" "Copying Local Missing $datatype  File(s)"
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
  fi
  errsize0=`cat $remotelocaldifflist|wc -l`
else
  errsize=0
  errsize0=$errsize
<<<<<<< HEAD
=======
<<<<<<< HEAD
  #touch $remotelocaldifflist
=======
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
  echo "$today $ctime: $server is offline, skipping remote & local comparison..."
fi 

ctime=`date --date='0 days ago' +%H:%M:%S`
tmperrsize=`echo "$errsize0 $errsize"|awk '{print($2-$1)}'`
echo "$today $ctime: $tmperrsize local missing $datatype file(s) copied from remote"

#checking local files' size
ctime=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime: Local $datatype File(s) Size Checking, please wait..."
$homepre/fso-data-check-local-cyg-cron.sh $localdrive $year $monthday $datatype $fileformat $stdsize > $logpath/check-local-$datatype-size.log &
waiting "$!" "Local $datatype File(s) Size Checking" "Checking Local $datatype File(s) Size"
<<<<<<< HEAD
errsize1=`cat $localwrongsize|wc -l`
=======
<<<<<<< HEAD
if [ $? -ne 0 ]; then
  ctime3=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime3: Local $datatype File(s) Size Check Failed!"
  exit 1
fi
if [ -f $localwrongsize ];then 
  errsize1=`cat $localwrongsize|wc -l`
  if [ $errsize1 -eq 0 ]; then
    errsize1=0
  fi
else
  errsize1=0
fi
=======
errsize1=`cat $localwrongsize|wc -l`
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402

ctime=`date --date='0 days ago' +%H:%M:%S`
if [ $pingres -ne 0 ];then 
  #copying local wrong size files from remote
  echo "$today $ctime: $datatype Wrong Size File(s) Copying, please wait..."
<<<<<<< HEAD
  $homepre/fso-copy-wget-error-cron-cyg.sh $server $port $user $password $localdrive $localwrongsize $datatype $stdsize > $logpath/$datatype-local-wrongsize-copy-$year$monthday.log &
=======
<<<<<<< HEAD
  $homepre/fso-copy-wget-error-cron-cyg.sh $server $port $user $password $localdrive $localwrongsize $stdsize > $logpath/$datatype-local-wrongsize-copy-$year$monthday.log &
=======
  $homepre/fso-copy-wget-error-cron-cyg.sh $server $port $user $password $localdrive $localwrongsize $datatype $stdsize > $logpath/$datatype-local-wrongsize-copy-$year$monthday.log &
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
  waiting "$!" "Local $datatype Wrong Size File(s) Copying" "Copying Local $datatype Wrong Size File(s)"
else
  echo "$today $citme: Skipping Copying Local Wrong Size $datatype File(s) from Remote..."
fi
<<<<<<< HEAD

errsize2=`cat $localwrongsize|wc -l`

=======

errsize2=`cat $localwrongsize|wc -l`

>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
#final corrected file(s) left
errsize3=`echo "$errsize0 $errsize2"|awk '{print($1+$2)}'`
#add total number of wrong file(s)
errsize4=`echo "$errsize $errsize1"|awk '{print($1+$2)}'`

ctime3=`date --date='0 days ago' +%H:%M:%S`

<<<<<<< HEAD
#$tmp1=`cat $remotelocaldifflist|wc -l`
#$tmp2=`cat $localwrongsize|wc -l`
cat $remotelocaldifflist > $tmplist
cat $localwrongsize >> $tmplist
=======
<<<<<<< HEAD
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402

ctime3=`date --date='0 days ago' +%H:%M:%S`
echo "                  For $year$monthday $datatype Data File(s)" > $logpath/errtmp-$year$monthday
echo "$today $ctime3 : $errsize0 Error $datatype File(s) in Local Missing File(s) Checking" >> $logpath/errtmp-$year$monthday
cat $remotelocaldifflist >> $logpath/errtmp-$year$monthday

echo "                " >> $logpath/errtmp-$year$monthday
echo "                  $errsize2 Error $datatype File(s) in Local Wrong Size File(s) Checking" >> $logpath/errtmp-$year$monthday
cat $localwrongsize >> $logpath/errtmp-$year$monthday

<<<<<<< HEAD
=======
if [ -f $localwrongsize ];then 
  cat $localwrongsize >> ./errtmp
fi 
=======
#$tmp1=`cat $remotelocaldifflist|wc -l`
#$tmp2=`cat $localwrongsize|wc -l`
cat $remotelocaldifflist > $tmplist
cat $localwrongsize >> $tmplist

ctime3=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime3: For $year$monthday $datatype Data File(s)" > $logpath/errtmp-$datatype-$year$monthday
echo "                   $errsize0 Error $datatype File(s) in Local Missing File(s) Checking" >> $logpath/errtmp-$datatype-$year$monthday
cat $remotelocaldifflist >> $logpath/errtmp-$datatype-$year$monthday

echo "                " >> $logpath/errtmp-$datatype-$year$monthday
echo "                   $errsize2 Error $datatype File(s) in Local Wrong Size File(s) Checking" >> $logpath/errtmp-$datatype-$year$monthday
cat $localwrongsize >> $logpath/errtmp-$datatype-$year$monthday

>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402

#cat $remotelocaldifflist $errlist > $tmplist 
errsize5=`cat $tmplist|wc -l`

ctime3=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime3: Sending notification email to Observation Assistant..."
#sending email to observers
<<<<<<< HEAD
email -s "$year$monthday-$datatype@fso-data: $errsize5 Error $datatype File(s) Found" nvst_obs@ynao.ac.cn < $logpath/errtmp-$year$monthday
email -s "$year$monthday-$datatype@fso-data: $errsize5 Error $datatype File(s) Found" chd@ynao.ac.cn < $logpath/errtmp-$year$monthday

=======
<<<<<<< HEAD
if [ $errsize3 -eq 0 ]; then
  echo "$today $ctime3: $datatype data under $destpre/$year$monthday/$datatype are O.K.!" | email -s "$year$monthday-$datatype@fso-data: $errsize3 Error File(s) Found" nvst_obs@ynao.ac.cn
  echo "$today $ctime3: $datatype data under $destpre/$year$monthday/$datatype are O.K.!" | email -s "$year$monthday-$datatype@fso-data: $errsize3 Error File(s) Found" chd@ynao.ac.cn
else
  email -s "$year$monthday-$datatype@fso-data: $errsize3 Error File(s) Found" nvst_obs@ynao.ac.cn < ./errtmp
  email -s "$year$monthday-$datatype@fso-data: $errsize3 Error File(s) Found" chd@ynao.ac.cn < ./errtmp
fi
=======
email -s "$year$monthday-$datatype@fso-data: $errsize5 Error $datatype File(s) Found" nvst_obs@ynao.ac.cn < $logpath/errtmp-$datatype-$year$monthday
email -s "$year$monthday-$datatype@fso-data: $errsize5 Error $datatype File(s) Found" chd@ynao.ac.cn < $logpath/errtmp-$datatype-$year$monthday

>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402


ctime4=`date --date='0 days ago' +%H:%M:%S`
today0=`date --date='0 days ago' +%Y%m%d`
#st2=`echo $ctime4|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
st2=`date +%s`
stdiff=`echo "$st1 $st2"|awk '{print($2-$1)}'`

echo "$today0 $ctime4: Checking & Copying $datatype data @ FSO finished!"
<<<<<<< HEAD
#echo "           Total : $errsize4 error file(s) found"
echo "                 : $errsize5 file(s) left"
echo "                 : see $tmplist for all file(s) details"
=======
<<<<<<< HEAD
echo "           Total : $errsize4 error file(s) found"
echo "                 : $errsize3 file(s) not corrected"
=======
#echo "           Total : $errsize4 error file(s) found"
echo "                 : $errsize5 file(s) left"
echo "                 : see $tmplist for all file(s) details"
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
echo "                 : $errsize0 file(s) found in remote local comparison"
echo "                 : see $remotelocaldifflist for details "
echo "                 : $errsize2 file(s) found in local wrong size checking"
echo "                 : see $localwrongsize for details"
<<<<<<< HEAD
=======
<<<<<<< HEAD
echo "                 : see $tmplist for details"
=======
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
echo "       Time Used : $stdiff secs."
echo "            From : $today $ctime1"
echo "              To : $today0 $ctime4"
echo "================================================================================="
rm -rf $lockfile
<<<<<<< HEAD
rm -f $logpath/errtmp-$year$monthday
=======
<<<<<<< HEAD
rm -f ./errtmp
=======
rm -f $logpath/errtmp-$datatype-$year$monthday
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402





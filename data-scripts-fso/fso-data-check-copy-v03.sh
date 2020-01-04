#!/bin/sh
#author: chen dong @fso
#purposes: check the data & copy the wrong file(s) again
#Usage: ./fso-data-check-copy-cron.sh ip port  destdir user password datatype(TIO or HA) threadnumber
#Example: ./fso-data-check-copy-cron.sh  192.168.111.120 21 /lustre/data tio ynao246135 2019 0918 fits 11062080
#Example: ./fso-data-check-copy-cron.sh  192.168.111.122 21 /lustre/data ha ynao246135 2019 0918 fits 2111040
#changlog: 
#       20190725   Release 0.1     first working version.sh
#                  Release 0.2     fixed some minor errors and revised display info
#       20190914   Release 0.3     Add comparison of remote & local file(s)
#       20191029   Release 0.31    Add more info to mail
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
  
  echo $'\n'             
  echo "$wtoday $wctime: $2 Task Has Done!"
  dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  echo "                   Finishing...."
  kill -6 $tmppid >/dev/null 1>&2
  echo "$dt1" > /home/chd/log/$(basename $0)-$datatype-sdtmp.dat
}

procing() {
  trap 'exit 0;' 6
  tput ed
  while [ 1 ]
  do
    for j in '-' '\\' '|' '/'
    do
      tput sc
      ptoday=`date --date='0 days ago' +%Y%m%d`
      pctime=`date --date='0 days ago' +%H:%M:%S`
      echo -ne  "$ptoday $pctime: $1...   $j"
      sleep 1
      tput rc
    done
  done
}
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
mday=`date --date='0 days ago' +%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"

if [ $# -ne 9 ];then
<<<<<<< HEAD
  echo "Usage: ./fso-data-check-copy-v03.sh ip port  destdir user password datatype(TIO or HA) fileformat stdsize"
  echo "Example: ./fso-data-check-copy-v03.sh  192.168.111.120 21 /lustre/data tio ynao246135 2019 0918 fits 11062080"
  echo "Example: ./fso-data-check-copy-v03.sh  192.168.111.122 21 /lustre/data ha ynao246135 2019 0918 fits 2111040"
=======
<<<<<<< HEAD
  echo "Usage: ./fso-data-check-copy-cron.sh ip port  destdir user password datatype(TIO or HA) fileformat stdsize"
  echo "Example: ./fso-data-check-copy-cron.sh  192.168.111.120 21 /lustre/data tio ynao246135 2019 0918 fits 11062080"
  echo "Example: ./fso-data-check-copy-cron.sh  192.168.111.122 21 /lustre/data ha ynao246135 2019 0918 fits 2111040"
=======
  echo "Usage: ./fso-data-check-copy-v03.sh ip port  destdir user password datatype(TIO or HA) fileformat stdsize"
  echo "Example: ./fso-data-check-copy-v03.sh  192.168.111.120 21 /lustre/data tio ynao246135 2019 0918 fits 11062080"
  echo "Example: ./fso-data-check-copy-v03.sh  192.168.111.122 21 /lustre/data ha ynao246135 2019 0918 fits 2111040"
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
  exit 1
fi
server=$1
port=$2
destpre=$3
user=$4
password=$5
year=$6
monthday=$7
fileformat=$8
stdsize=$9

datatype=`echo $user|tr -t 'a-z' 'A-Z'`

homepre="/home/chd"
syssep="/"
logpath=$homepre/log

#errlist=/home/chd/log/$datatype-$today-remote.list
# remote & local diff list
remoteerrlist=$logpath/$datatype-$fileformat-$year$monthday-diff.list
# local wrongsize list
errlist=$logpath/$datatype-local-wrongsize-$year$monthday.list
targetdir=$destpre/$year/$year$monthday
tmplist=$logpath/$datatype-$fileformat-$year$monthday-tmp.list

touch $remoteerrlist
touch $errlist
touch $tmplist

<<<<<<< HEAD
lockfile=$logpath/$(basename $0)-$datatype-$year$monthday.lock
=======
<<<<<<< HEAD
lockfile=$logpath/$(basename $0)-$datatype.lock
=======
lockfile=$logpath/$(basename $0)-$datatype-$year$monthday.lock
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402

if [ -f $lockfile ];then
  mypid=$(cat $lockfile)
  ps -p $mypid | grep $mypid &>/dev/null
  if [ $? -eq 0 ];then
    echo "$today $ctime: $(basename $0) is running for syncing $datatype data..." 
    exit 1
  else
    echo $$>$lockfile
  fi
else
  echo $$>$lockfile
fi

ctime0=`date --date='0 days ago' +%H:%M:%S`
#st1=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
st1=`date +%s`
echo "                                                       "
echo "======= Welcome to Data Archiving System @ FSO! ======="
echo "              fso-data-check-copy.sh                   "
echo "          (Release 0.31 20191029 20:50)                "
echo "                                                       "
echo "           Check $datatype data and copy               "
echo "                                                       "
echo "                $today $ctime0                         "
echo "======================================================="
echo " "
cd $homepre
ctime1=`date --date='0 days ago' +%H:%M:%S`
touch $logpath/pingtmp
echo "$today $ctime1: Testing $server is online or not, please wait..."
ping $server -c 5 | grep ttl >> $logpath/pingtmp
pingres=`cat $logpath/pingtmp | wc -l`
rm -f $logpath/pingtmp
ctime1=`date --date='0 days ago' +%H:%M:%S`
if [ $pingres -ne 0 ];then 
#comparing remote and local file(s),creat local missing file(s)
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime1: $server is online..."
  echo "$today $ctime1: Remote & Local $datatype File(s) Checking, please wait..."
  #/home/chd/fso-data-check-remote-cron.sh 192.168.111.120 21 tio ynao246135 2019 0913 TIO fits
  $homepre/fso-data-check-remote-cron.sh $server $port $user $password $year $monthday $datatype $fileformat > $logpath/check-remote-$datatype-$year$monthday.log &
  waiting "$!" "Remote & Local $datatype File(s) Checking" "Checking Remote & Local $datatype File(s)"
  #if [ $? -ne 0 ];then
  #  ctime3=`date --date='0 days ago' +%H:%M:%S`
  #  echo "$today $ctime3: $datatype Check Failed!"
  #  cd $homepre
  #  exit 1
  #fi
<<<<<<< HEAD
 
  remoteerrsize=`cat $remoteerrlist|wc -l`
  
=======
<<<<<<< HEAD
  if [ -f $remoteerrlist ]; then 
    remoteerrsize=`cat $remoteerrlist|wc -l`
    if [ $remoteerrsize -eq 0 ]; then
      remoteerrsize=0
    fi
  else
    remoteerrsize=0
  fi

=======
 
  remoteerrsize=`cat $remoteerrlist|wc -l`
  
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
  #copying local missing file(s) from remote server
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: Copying local missing $datatype file(s) from remote, please wait..."
  $homepre/fso-copy-wget-error-cron-v02.sh $server $port $user $password $destpre $remoteerrlist $stdsize > $logpath/remote-$datatype-error-copy-$year$monthday.log &
  waiting "$!" "Local $datatype Missing File(s) Copying" "Copying Local Missing $datatype Data from Remote"
  #if [ $? -ne 0 ];then
  #  ctime3=`date --date='0 days ago' +%H:%M:%S`
  #  echo "$today $ctime3: $datatype Copy Failed!"
  #  cd /home/chd/
  #  exit 1
  #fi
  
  remoteerrsize1=`cat $remoteerrlist|wc -l`
else
  echo "$today $ctime1: $server is offline, skip checking remote & local file(s)..."
<<<<<<< HEAD
  remoteerrsize=`cat $remoteerrlist|wc -l`
=======
<<<<<<< HEAD
  
  if [ -f $remoteerrlist ]; then 
    remoteerrsize=`cat $remoteerrlist|wc -l`
  else
    remoteerrsize=0
  fi
=======
  remoteerrsize=`cat $remoteerrlist|wc -l`
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
  remoteerrsize1=$remoteerrsize  
fi

#checking local wrong size file(s)
if [ -d $targetdir ]; then 
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: Local Wrong Size $datatype File(s) Checking, please wait..."
  $homepre/fso-data-check-local-cron.sh $destpre $year $monthday $datatype $fileformat $stdsize > $logpath/check-local-$datatype-size-$year$monthday.log &
  waiting "$!" "Local Wrong Size $datatype File(s) Checking" "Checking Local Wrong Size $datatype File(s)"
<<<<<<< HEAD
=======
<<<<<<< HEAD
  if [ $? -ne 0 ];then
    ctime3=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime3: $datatype Check Failed!"
    cd $homepre
    exit 1
=======
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
  #if [ $? -ne 0 ];then
  #  ctime3=`date --date='0 days ago' +%H:%M:%S`
  #  echo "$today $ctime3: $datatype Check Failed!"
  #  cd $homepre
  #  exit 1
  #fi
  errsize1=`cat $errlist|wc -l`
  
<<<<<<< HEAD
=======
  #correcting local wrong size file(s)...
  if [ $pingres -ne 0 ];then 
    ctime=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime: Wrong size local $datatype File(s) Copying from remote, please wait..."
    $homepre/fso-copy-wget-error-cron-v02.sh $server $port $user $password $destpre $errlist $stdsize> $logpath/local-$datatype-error-copy-$year$monthday.log &
    waiting "$!" "Local Wrong Size $datatype File(s) Copying" "Copying Local Wrong Size $datatype File(s) from Remote"
    #if [ $? -ne 0 ];then
    #  ctime3=`date --date='0 days ago' +%H:%M:%S`
    #  echo "$today $ctime3: $datatype Copy Failed!"
    #  cd $homepre
    #  exit 1
    #fi
    if [ -f $errlist ]; then
      errsize2=`cat $errlist|wc -l`
    else
      errsize2=0
    fi
  else
    ctime3=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime3: Skip correcting local wrong size $datatype File(s)!"
    errsize2=`cat $errlist|wc -l`
    cd $homepre
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
  fi
  if [ -f $errlist ]; then
    errsize1=`cat $errlist|wc -l`
    if [ $errsize1 -eq 0 ]; then
      errsize1=0
    fi
  else
    errsize1=0
  fi
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
  #correcting local wrong size file(s)...
  if [ $pingres -ne 0 ];then 
    ctime=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime: Wrong size local $datatype File(s) Copying from remote, please wait..."
    $homepre/fso-copy-wget-error-cron-v02.sh $server $port $user $password $destpre $errlist $stdsize> $logpath/local-$datatype-error-copy-$year$monthday.log &
    waiting "$!" "Local Wrong Size $datatype File(s) Copying" "Copying Local Wrong Size $datatype File(s) from Remote"
    #if [ $? -ne 0 ];then
    #  ctime3=`date --date='0 days ago' +%H:%M:%S`
    #  echo "$today $ctime3: $datatype Copy Failed!"
    #  cd $homepre
    #  exit 1
    #fi
    if [ -f $errlist ]; then
      errsize2=`cat $errlist|wc -l`
    else
      errsize2=0
    fi
  else
    ctime3=`date --date='0 days ago' +%H:%M:%S`
    echo "$today $ctime3: Skip correcting local wrong size $datatype File(s)!"
    errsize2=`cat $errlist|wc -l`
    cd $homepre
  fi
else
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: $targetdir doesn't exist, please check!"
<<<<<<< HEAD
  errsize2=`cat $errlist|wc -l`
=======
<<<<<<< HEAD
  
  if [ -f $errlist ]; then
    errsize2=`cat $errlist|wc -l`
  else
    errsize2=0
  fi
  
=======
  errsize2=`cat $errlist|wc -l`
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
fi 
#errsize2=`cat $errlist|wc -l`
#add local missing files' no. and local wrong size's no. 
errsize3=`echo "$remoteerrsize $errsize1"|awk '{print($2+$1)}'`
errsize4=`echo "$remoteerrsize1 $errsize2"|awk '{print($2+$1)}'`

ctime3=`date --date='0 days ago' +%H:%M:%S`
<<<<<<< HEAD
=======
<<<<<<< HEAD
cat $remoteerrlist $errlist > $tmplist

echo "$today $ctime3: $remoteerrsize1 Local Missing File(s):" > ./errtmp
cat $remoteerrlist >> ./errtmp
echo "                " >> ./errtmp
echo "$today $ctime3: $errsize2 Local Wrong Size File(s):" >> ./errtmp
cat $errlist >> ./errtmp
=======
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
tmp1=`cat $remoteerrlist|wc -l`
tmp2=`cat $errlist|wc -l`
cat $remoteerrlist  > $tmplist
cat $errlist >> $tmplist

<<<<<<< HEAD
echo "                   For $year$monthday  $datatype Data File(s)" > $logpath/errtmp-$datatype-$year$monthday
echo "************************************************************************************************************">> $logpath/errtmp-$datatype-$year$monthday
echo " $today $ctime3 : $tmp1 Local Missing File(s)" >> $logpath/errtmp-$datatype-$year$monthday
cat $remoteerrlist >> $logpath/errtmp-$datatype-$year$monthday
echo "                " >> $logpath/errtmp-$datatype-$year$monthday
echo " $today $ctime3 : $tmp2 Local Wrong Size File(s)" >> $logpath/errtmp-$datatype-$year$monthday
cat $errlist >> $logpath/errtmp-$datatype-$year$monthday
=======
echo "$today $ctime3: For $year$monthday  $datatype Data File(s)" > $logpath/errtmp-$datatype-$year$monthday
echo "                 : $tmp1 Local Missing File(s)" >> $logpath/errtmp-$datatype-$year$monthday
cat $remoteerrlist >> $logpath/errtmp-$datatype-$year$monthday
echo "                " >> $logpath/errtmp-$datatype-$year$monthday
echo "                 : $tmp2 Local Wrong Size File(s)" >> $logpath/errtmp-$datatype-$year$monthday
cat $errlist >> $logpath/errtmp-$datatype-$year$monthday
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402

errsize5=`cat $tmplist|wc -l`

ctime3=`date --date='0 days ago' +%H:%M:%S`
#sending email to observers
echo "$today $ctime3: Sending Email to Observation Assistants..."
<<<<<<< HEAD
=======
<<<<<<< HEAD
if [ $errsize4 -eq 0 ]; then
  echo "$today $ctime3: $datatype data under /lustre/data/$year/$year$monthday/$datatype are O.K.!" | mail -s "$year$monthday-$datatype@lustre: $errsize4 Error File(s) Found" nvst_obs@ynao.ac.cn
  echo "$today $ctime3: $datatype data under /lustre/data/$year/$year$monthday/$datatype are O.K.!" | mail -s "$year$monthday-$datatype@lustre: $errsize4 Error File(s) Found" chd@ynao.ac.cn
else
  mail -s "$year$monthday-$datatype@lustre: $errsize4 Error File(s) Found" nvst_obs@ynao.ac.cn < ./errtmp
  mail -s "$year$monthday-$datatype@lustre: $errsize4 Error File(s) Found" chd@ynao.ac.cn < ./errtmp
fi
=======
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
#if [ $errsize4 -eq 0 ]; then
#  echo "$today $ctime3: $datatype data under /lustre/data/$year/$year$monthday/$datatype are O.K.!" | mail -s "$year$monthday-$datatype@lustre: $errsize4 Error File(s) Found" nvst_obs@ynao.ac.cn
#  echo "$today $ctime3: $datatype data under /lustre/data/$year/$year$monthday/$datatype are O.K.!" | mail -s "$year$monthday-$datatype@lustre: $errsize4 Error File(s) Found" chd@ynao.ac.cn
#else
mail -s "$year$monthday-$datatype@lustre: $errsize5 Error File(s) Found" nvst_obs@ynao.ac.cn < $logpath/errtmp-$datatype-$year$monthday
mail -s "$year$monthday-$datatype@lustre: $errsize5 Error File(s) Found" chd@ynao.ac.cn < $logpath/errtmp-$datatype-$year$monthday
#fi
<<<<<<< HEAD
=======
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402

ctime4=`date --date='0 days ago' +%H:%M:%S`
#st2=`echo $ctime4|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
st2=`date +%s`
stdiff=`echo "$st1 $st2"|awk '{print($2-$1)}'`
today0=`date --date='0 days ago' +%Y%m%d`

echo "$today $ctime4: Checking & Copying $datatype data on $year$monthday finished!"
<<<<<<< HEAD
=======
<<<<<<< HEAD
echo "          Before : $errsize3 error file(s) Found!"
echo "           After : $errsize4 error file(s) left!"
echo "                 : $remoteerrsize1 error file(s) in remote-local comparison"
echo "                 : $errsize2 error files in local wrong size checking"
=======
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
#echo "          Before : $errsize3 error file(s) Found!"
echo "           After : $errsize5 error file(s) left!"
echo "                 : $tmp1 error file(s) in remote-local comparison"
echo "                 : $tmp2 error file(s) in local wrong size checking"
<<<<<<< HEAD
=======
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402
echo "                 : see $tmplist for details"
echo "       Time Used : $stdiff secs."
echo " Total Time From : $today $ctime0"
echo "              To : $today0 $ctime4"
echo "================================================================================="
rm -rf $lockfile
<<<<<<< HEAD
rm -f $logpath/errtmp-$datatype-$year$monthday
=======
<<<<<<< HEAD
rm -f ./errtmp
=======
rm -f $logpath/errtmp-$datatype-$year$monthday
>>>>>>> b1b3960921e4d0d15c04a99f3a3123de483be9c0
>>>>>>> 0f956503957fe885bfb5ea3c2ec34db5776bd402




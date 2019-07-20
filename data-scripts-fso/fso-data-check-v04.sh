#!/bin/bash
#monitor the size of dest dir every 10 secs. 
#usage: ./du-monitor.sh yourdir delaytime(in secs.)
#example: ./du-monitor.sh /lustre/data/tmp 10
#press ctrl-c to break the script

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
                ptoday=`date --date='0 days ago' +%Y%m%d`
                pctime=`date --date='0 days ago' +%H:%M:%S`
                echo -ne  "$ptoday $pctime: $1...   $j"
                sleep 1
                tput rc
          done
        done
}

if [ $# -ne 3 ];then
  echo "usage: ./fso-data-check-xx.sh /youdirhere/ fileformat standardsize(in bytes)"
  echo "example: ./fso-data-check-xx.sh /lustre/data/tmp/ fits 11062080"
  exit 0
fi

today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
cdir=$1
fileformat=$2
stdsize=$3

syssep="/"
list=/home/chd/log/$fileformat-$today-$ctime.list
fn=/home/chd/log/$fileformat-$today-$ctime-number.dat
errorlist=/home/chd/result/$fileformat-of-wrong-size-$today-$ctime.list

if [ ! -d "$cdir" ];then
  echo "Target Dir: $cdir     doesn't exist...."
  echo "Please check..."
  exit 0
fi
ctime=`date --date='0 days ago' +%H:%M:%S`
t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
echo " "
echo "================================================================================"
echo " "
echo "$today $ctime : Checking the $fileformat file numbers & size                   "
echo "                    @ $cdir"
echo "                    Please wait..."
echo "                    Press ctrl-c to break! "
echo " " 
echo "================================================================================"
echo " "
cd $cdir
ls -lR . | grep $fileformat | wc -l > $fn &
waiting "$!" "$fileformat file(s) number getting" "Getting $fileformat file(s) number"
find  $PWD | xargs ls -ld| grep $fileformat | awk '{print $9"  "$5}' > $list &
waiting "$!" "$fileformat file(s) info getting" "Getting $fileformat file(s) info"
cat $list |awk '{ if ($2!='''$stdsize''') {print $1"  "$2}}' > $errorlist &
waiting "$!" "Wrong $fileformat file(s) checking" "Checking wrong $fileformat file(s)"
errorline=`cat $errorlist|wc -l`
curnum=$(cat $fn)
today=`date --date='0 days ago' +%Y%m%d`
ctime1=`date --date='0 days ago' +%H:%M:%S`
t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
if [ $timediff -lt 0 ]; then
  timediff=0
fi
echo "$today $ctime1: For $fileformat Data File(s) @ $cdir "
echo "     File Checked: $curnum file(s)" 
echo "            Found: $errorline file(s) in wrong size"
echo "        Time Used: $timediff secs."
echo "  Error File List: $errorlist"
echo " "
echo "================================================================================"

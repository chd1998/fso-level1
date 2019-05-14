#!/bin/bash
#author: chen dong @fso
#purposes: kill process periodically to avoid poor performance
#usage:  ./proc-kill.sh procname time(in sec.)
#example: ./proc-kill.sh tio-sync.sh 14400
#changlog:
#       20190427        release 0.1     
#                       release 0.2	add support to arguments

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    exit 1
}

today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`

if [ $# -ne 3 ];then
  echo "usage:  ./proc-kill.sh procname timelimit(in sec.) delaytime(in sec.)"
  echo "example: ./proc-kill.sh tio-sync.sh 14400 10"
  exit 1
fi

echo "===== Welcome to Data Archiving System @FSO! ====="
echo "               proc-kill.sh Release 0.2           "
echo "                  20190427 23:01                  "
echo "                press ctrl-c to quit              "
echo " "
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S` 

if [ $# -ne 3 ];then
  echo "usage:  ./proc-kill.sh procname totaltime(in sec.) checktime(in sec.)"
  echo "example: ./proc-kill.sh tio-sync.sh 14400 10"
  exit 1
fi

p_name=$1
timelimit=$2
delaytime=$3

echo "$today $ctime: Monitoring $p_name ..."

while true
do
  ctime=`date --date='0 days ago' +%H:%M:%S` 
  #echo "$today $ctime: Monitoring $p_name ..."
  pid="$(pgrep $p_name)"
  #pid=`ps -eo pid | awk '{print $1}'|grep $p_name`
  #pid="$(ps x|grep longtimetest.sh|grep -v grep|awk '{print $1}')"
  #echo $pid
  #read 
  if [  -z $pid ];then
    echo "$today $ctime: $p_name is not running ..."
    exit 1
  fi
  runtime=`ps -p $pid -o etime= | tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  if [ $? -ne 0 ];then
    echo "couldn't calculate runtime for $p_name..."
  fi
  #ptime="$(ps -eo pid,etime|grep $pid|awk '{print $2}' |head -n1)"
  #runtime=`echo $ptime|awk '{split($1,tab,/:/); print tab[2]+tab[1]*60 }'`
  echo "$today $ctime: $p_name($pid) has run for $runtime secs. "
  #if time > timelimit , kill it 
  ctime=`date --date='0 days ago' +%H:%M:%S`
  if [ $runtime -ge $timelimit ];then
    kill  $pid
    if [ $? -ne 0 ];then
      echo "$today $ctime: $p_name($pid) runs $ptime secs. "
      echo "                   killing $p_name($pid)..."
      echo "                   kill $pname($pid) FAILED!"
      exit 1
    else
      echo "$today $ctime: $p_name($pid) runs $ptime secs. "
      echo "                   killing $p_name($pid)..."
      echo "                   kill $pname($pid) succeeded!"
      exit 0
    fi
  fi
# sleep delaytime secs. for next checking...
  sleep $delaytime
done


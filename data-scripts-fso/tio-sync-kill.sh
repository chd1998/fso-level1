
#!/bin/bash
#author: chen dong @fso
#purposes: kill tio-sync.sh every 4 hrs to avoid poor performance
#usage:  run in crontab every 4 hrs 
#example: none
#changlog:
#       20190427        release 0.1
#       20190507        release 0.2	fixed some errors
#   	20190508        release 0.3     fixed method in get pid of process     

trap 'onCtrlC' INT
function onCtrlC(){
    echo 'ctrl-c'
    exit 1
}

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`

if [ $# -ne 2 ];then
  echo "usage: ./tio-sync-kill.sh timelimit(in secs.) delaytime(in secs.)"
  echo "example: ./tio-sync-kill.sh 14400 10"
  echo "press ctrl-c to break!"
  exit 0
fi

timelimit=$1
delaytime=$2

echo " "
echo "===== Welcome to Data Archiving System @FSO! ====="
echo "           tio-sync-kill.sh Release 0.4           "
echo " "
p_name="tio-sync.sh"
p_name1="wget"

while true
do 
  echo "$today $ctime: Monitoring $p_name & $p_name1..."
  #pid="$(pidof $p_name)"
  pid="$(ps x|grep -w tio-sync.sh|grep -v grep|awk '{print $1}'|head -n1)"
  #echo "$pid"
  pid1="$(pidof $p_name1)"
  #runtime=0
  #runtime1=0

  if [ -z $pid ];then
    echo "                   $p_name: not found!"
    runtime=0
  else
    runtime=`ps -p $pid -o etime= | tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  fi

  if [ -z $pid1 ];then
    echo "                   $p_name1: not found!"
    runtime1=0
  else
    runtime1=`ps -p $pid1 -o etime= | tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++)  {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  fi

  #echo "$runtime"
  #echo "$runtime1"
  #read
  ctime=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime: "
  echo "                   $p_name($pid) 	==> $runtime secs..."
  echo "                   $p_name1($pid1) 		==> $runtime1 secs..."
  #echo "runtime: $runtime"
  #when time > 14400s , kill it 
  #timelimit=$1
  ctime=`date --date='0 days ago' +%H:%M:%S`

  if [ $runtime -ge $timelimit ];then
    kill $pid
    echo "$today $ctime: $p_name($pid) runs $runtime secs. "
    echo "                   killing $p_name($pid)..."
    echo "                   kill $pname($pid) succeeded!"
  fi

  ctime=`date --date='0 days ago' +%H:%M:%S`
  if [ $runtime1 -ge $timelimit ];then
    kill $pid1
    echo "$today $ctime: $p_name1($pid1) runs $runtime1 secs. "
    echo "                   killing $p_name1($pid1)..."
    echo "                   kill $pname1($pid1) succeeded!"
  fi
  echo " "
  sleep $delaytime
done

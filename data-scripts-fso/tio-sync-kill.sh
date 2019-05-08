
#!/bin/bash
#author: chen dong @fso
#purposes: kill tio-sync.sh every 4 hrs to avoid poor performance
#usage:  run in crontab every 4 hrs 
#example: none
#changlog:
#       20190427        release 0.1
#       20190507        release 0.2	fixed some errors
#   	20190508        release 0.3     fixed method in get pid of process     

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`

echo "===== Welcome to Data Archiving System @FSO! ====="
echo "           tio-sync-kill.sh Release 0.3           "
echo " "
p_name="tio-sync.sh"
p_name1="wget"

echo "$today $ctime: Monitoring $p_name & $p_name1..."
#pid="$(pidof $p_name)"
pid="$(ps x|grep -w tio-sync.sh|grep -v grep|awk '{print $1}'|head -n1)"
#echo "$pid"
pid1="$(pidof $p_name1)"
runtime=0
runtime1=0

if [ -z $pid ];then
  echo "$p_name  process not found!"
else
  runtime=`ps -p $pid -o etime= | tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
fi

if [ -z $pid1 ];then
  echo "$p_name1 process not found!"
else
  runtime1=`ps -p $pid1 -o etime= | tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++)  {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
fi

#echo "$runtime"
#echo "$runtime1"
#read
echo "$today $ctime: "
echo "                   $p_name($pid) has run for $runtime secs..."
echo "                   $p_name1($pid1) has run for $runtime1 secs..."
#echo "runtime: $runtime"
#when time > 14400s , kill it 
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`

if [ $runtime -ge 14400 ];then
  kill $pid
  echo "$today $ctime: $p_name($pid) runs $runtime secs. "
  echo "                   killing $p_name($pid)..."
  echo "                   kill $pname($pid) succeeded!"
fi
if [ $runtime1 -ge 14400 ];then
  kill $pid1
  echo "$today $ctime: $p_name1($pid1) runs $runtime1 secs. "
  echo "                   killing $p_name1($pid1)..."
  echo "                   kill $pname1($pid1) succeeded!"
fi

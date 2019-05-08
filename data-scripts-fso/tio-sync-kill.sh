
#!/bin/bash
#author: chen dong @fso
#purposes: kill tio-sync.sh every 4 hrs to avoid poor performance
#usage:  run in crontab every 4 hrs 
#example: none
#changlog:
#       20190427        release 0.1
#       20190507        release 0.2	fixed some errors     

echo "===== Welcome to Data Archiving System @FSO! ====="
echo "           tio-sync-kill.sh Release 0.2           "
echo "                  20190507 18:14                  "
echo " "
cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S` 
p_name="tio-sync.sh"
p_name1="wget"
echo "Monitoring $p_name & $p_name1..."
pid="$(pidof $p_name)"
pid1="$(pidof $p_name1)"
runtime=0
runtime1=0
if [ -z $pid ];then
  echo "$p_name  process not found!"
  if [ -z $pid1 ];then
    echo "$p_name1 process not found!"
    exit 0
  else
    runtime1=`ps -p $pid1 -o etime=|/home/chd/gettime.awk`
  fi
else
   runtime=`ps -p $pid -o etime=|/home/chd/gettime.awk`
fi
#echo "$runtime"
#echo "$runtime1"
#read
echo "$today $ctime: "
echo "                   $p_name has run for $runtime secs..."
echo "                   $p_name1 has run for $runtime1 secs..."
#echo "runtime: $runtime"
#if time > 14400s , kill it 
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

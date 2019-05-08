
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
pid="$(pgrep -f $p_name| awk "{print $1}"|head -n1) "
pid1="$(pgrep -f $p_name1)"
if [[ -z $pid || -z $pid1 ]];then
  echo "$p_name & $p_name1 process not found!"
  exit 0
fi
#echo "pid: $pid"
#echo "pid1: $pid1"
#read
ptime="$(ps -eo pid,etime|grep $pid|awk '{print $2}' |head -n1)"
ptime1="$(ps -eo pid,etime|grep $pid1|awk '{print $2}' |head -n1)"
#echo "running time: $ptime"
#echo "running time: $ptime1"
#read
runtime=`echo $ptime|awk '{split($1,tab,/:/); print tab[3]+tab[2]*60+tab[1]*3600 }'`
runtime1=`echo $ptime1|awk '{split($1,tab,/:/); print tab[3]+tab[2]*60+tab[1]*3600 }'`
echo "$today $ctime: "
echo "                   $p_name has run for $runtime secs..."
echo "                   $p_name1 has run for $runtime1 secs..."
#echo "runtime: $runtime"
#if time > 14400s , kill it 
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
if [ $runtime -ge "14400" ] || [ $runtime1 -ge "14400" ];then
  kill $pid
  kill $pid1
  echo "$today $ctime: $p_name($pid) runs $ptime secs. "
  echo "                   killing $p_name($pid)..."
  echo "                   kill $pname($pid) succeeded!"
fi


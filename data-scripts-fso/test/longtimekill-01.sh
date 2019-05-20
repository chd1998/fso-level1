
#!/bin/sh
 
p_name="longtimetest.sh"
while true
do
echo "Checking..."
sleep 5
#every 10s check
#pid="$(ps -ef|grep $p_name|awk '{print $2}'|head -n1)"
#pid="$(ps x | awk '/$p_name/{print $1}')"
pid="$(pgrep -f $p_name)"
echo "pid: $pid"
#read
ptime="$(ps -eo pid,etime|grep $pid|awk '{print $2}' |head -n1)"
echo "running time: $ptime"
runtime=`echo $ptime|awk '{split($1,tab,/:/); print tab[2]+tab[1]*60 }'`
echo "runtime: $runtime"
#read
#check if time exceed 5 mins.
#pstatus="$(echo $ptime|awk '{split($1,tab,/:/); if (tab[2]+tab[1]*60>=100) {print 1}else{print 0} }')"
#echo "running status:$pstatus"
#if time > 600s ,return 1,else 0 
if [ $runtime -ge "120" ];then
  echo "time>120s"
  read
  kill -9 $pid
  echo "kill success " $pid
else
  echo "waiting..."
fi
done

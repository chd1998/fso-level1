#!/bin/sh
now=`date '+%Y-%m-%d %H:%M:%S'`
smartdns_pid=`pidof smartdns`
if [ $? -ne 0 ];then
  smartdns_pid=0
fi
#echo $smartdns_pid
if [ $smartdns_pid -le 0 ]; then
  echo "$now : smartdns died...restarting" 
  /etc/init.d/smartdns restart
else
  echo "$now : smartdns is ok..."
fi
 

#!/bin/bash
now=`date '+%Y-%m-%d %H:%M:%S'`
srvstatus=`systemctl status vsftpd|grep active|grep running`
if [ $? -eq 1 ]; then
  echo "$now : vsftpd died, pls wait to restart..."
  systemctl restart vsftpd &
  wait $!
  echo "$now : vsftpd restarted!"
else
  echo "$now : vsftpd is ok!"
fi
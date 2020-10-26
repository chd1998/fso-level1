#!/bin/bash

now=`date '+%Y-%m-%d %H:%M:%S'`
vncstatus=`pidof vsftpd`
if [ $vncstatus -le 0 ]; then
  echo "$now : vsftpd died, pls wait to restart..."
  /etc/init.d/vsftpd restart &
  wait $!
  echo "$now : vsftpd restarted!"
else
  echo "$now : vsftpd is ok!"
fi


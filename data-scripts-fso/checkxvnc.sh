#!/bin/bash

now=`date '+%Y-%m-%d %H:%M:%S'`
vncstatus=`pidof Xvnc`
if [ $vncstatus -le 0 ]; then
  vncserver &
  wait $!
  echo "$now : vncserver restarted!"
else
  echo "$now : vncserver is ok!"
fi


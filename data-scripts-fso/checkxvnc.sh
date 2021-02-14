#!/bin/bash

now=`date '+%Y-%m-%d %H:%M:%S'`
pidof Xvnc > /dev/null 2>&1
if [ $? -eq 1 ]; then
  echo "$now : vncserver died, pls wait to restart..."
  vncserver &
  wait $!
  now=`date '+%Y-%m-%d %H:%M:%S'`
  if [ $? -eq 0 ]; then
    echo "$now : vncserver restarted!"
  else
    echo "$now : vncserver restart failed!"
  fi
else
  echo "$now : vncserver is ok!"
fi


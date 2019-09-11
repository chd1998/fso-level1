#!/bin/sh

if [ $# -ne 1 ];then
  echo "usage: ./proc-kill.sh procname"
  echo "example: ./proc-kill.sh fso-data-check-cron.sh"
  exit 0
fi
ps aux|grep $1 |grep -v grep |awk '{print $2}'| xargs kill


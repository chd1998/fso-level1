#!/bin/bash
#lsof -e /run/user/1000/gvfs -n /fso-cache |grep deleted|awk '{print $2}'|xargs kill -9
find /proc/*/fd -ls 2> /dev/null | awk '/deleted/ {print $11}' | xargs  -n 1 truncate -s 0
rm -rf /phpstudy/www/kodexplorer4.40/data/User/admin/recycle_kod/
rm -rf /root/.lftp/transfer* 
#rm -f /fso-cache/*

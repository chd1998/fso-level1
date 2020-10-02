#!/bin/sh
#usage: check-curlftpfs.sh
pname=curlftpfs
day=$(date "+%Y-%m-%d")
ctime=$(date "+%H:%M:%S")
ps -aux|grep $pname|grep -v grep >/dev/null 2>&1
#echo $cpid
if [ $? -ne 0 ];then
  echo "$day $ctime : Couldn't find $pname..."
  echo "                    : Restart $pname... "
  systemctl restart addftpdir.service
  if [ $? -eq 0 ];then
    day=$(date "+%Y-%m-%d")
    ctime=$(date "+%H:%M:%S")
    echo "$day $ctime : Restart succeeded!"
  else
    echo "$day $ctime : Restart Failed!"
    echo "$day $ctime : Pls check..."
  fi
else
  echo "$day $ctime : $pname is running..."
fi

#!/bin/sh
#usage: check process alive or not

if [ $# -ne 1 ];then
  echo "Usage: ./check-process.sh processname"
  echo "Example: ./check-process.sh  srs"
  exit 1
fi
pname=$1
day=$(date "+%Y-%m-%d")
ctime=$(date "+%H:%M:%S")
status=`/etc/init.d/$pname status|grep running`
slen=${#status}
#echo $cpid
if [ $slen -eq 0 ];then
  echo "$day $ctime : Couldn't find $pname..."
  echo "                    : Restart $pname... "
  #systemctl restart addftpdir.service
  /etc/init.d/$1 restart
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

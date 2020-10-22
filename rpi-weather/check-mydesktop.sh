#!/bin/sh
#usage: check process alive or not

#if [ $# -ne 1 ];then
#  echo "Usage: ./check-process.sh processname"
#  echo "Example: ./check-process.sh "
#  exit 1
#fi
pname='chromium-browser'
day=$(date "+%Y-%m-%d")
ctime=$(date "+%H:%M:%S")
#status=`/etc/init.d/$pname status|grep running`
#slen=${#status}
#cpid=`pidof $1`
#echo $cpid
ps -aux|grep $pname|grep -v grep|awk '{print $2}'>chromiumpid
num=`cat chromiumpid|wc -l`
if [ $num -le 0 ];then
  echo "$day $ctime : Couldn't find $pname..."
  echo "                    : Restart $pname... "
  #systemctl restart addftpdir.service
  #/etc/init.d/$1 restart
  DISPLAY=:0 chromium-browser -kiosk --incognito 'http://localhost:8080' > /dev/null 2>&1  &
  if [ $? -eq 0 ];then
    day=$(date "+%Y-%m-%d")
    ctime=$(date "+%H:%M:%S")
    echo "$day $ctime : Restart $pname succeeded!"
  else
    echo "$day $ctime : Restart $pname Failed!"
    echo "$day $ctime : Pls check..."
  fi
else
  echo "$day $ctime : $pname is running..."
fi
rm -f chromiumpid

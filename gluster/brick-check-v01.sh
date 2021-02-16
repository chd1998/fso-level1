#!/bin/bash
# $1 is the volume name of gluster cluster

if [ $# -ne 1 ];then
  echo "Usage: .$(basename $0) volume_name"
  echo "Example: $(basename $0)  df3600"
  exit 1
fi

volname=$1

gluster volume status $volname detail|grep -E '{Brick|Online}' > ./brick-$volname.tmp

#goodnum=`cat ./bricklist-$volname.tmp|grep Online|grep Y|wc -l`
cat ./brick-$volname.tmp|grep -E '{Brick|Online|N}'|grep Brick > ./birck-bad-$volname.tmp

if [ ! -f ./brick-bad-$volname.tmp ]; then
  touch ./brick-bad-$volname.tmp
fi
badlist=`cat ./brick-bad-$volname.tmp|wc -l`
today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
if [ $badlist -gt 0 ]; then
  echo "                    Bad Brick(s) list"
  for brickname in $(cat ./brick-bad-$volname.tmp);
  do
    today=`date  +%Y%m%d`
    ctime=`date  +%H:%M:%S`
    echo "$today $ctime : $brickname "
  done
else
  echo  "$today $ctime : no bad brick(s) found in $volname..."
fi
rm -f ./brick-*.tmp
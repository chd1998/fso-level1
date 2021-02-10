#!/bin/bash
# $1 is the volume name of gluster cluster

if [ $# -ne 1 ];then
  echo "Usage: .$(basename $0) volume_name"
  echo "Example: $(basename $0)  df3600"
  exit 1
fi

volname=$1

gluster volume status $volname deatail|grep -E 'Brick|Online' > ./bricklist-$volname.tmp

#goodnum=`cat ./bricklist-$volname.tmp|grep Online|grep Y|wc -l`
cat ./bricklist-$volname.tmp|grep -E 'Brick|Online|N/A'|grep Brick > ./birck-bad-$volname.tmp

today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
echo "                    Bad Brick(s) list"
for brickname in $(cat ./brick-bad-$volname.tmp);
do
  today=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  echo "$today $ctime : $brickname "
done
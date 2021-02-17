#!/bin/bash
# $1 is the volume name of gluster cluster
# Chang log:
#               20210216        0.1.0 : First working protype
#               20210217        0.1.1 : Test volume is exist or not

if [ $# -ne 1 ];then
  echo "Usage: .$(basename $0) volume_name"
  echo "Example: $(basename $0)  df3600"
  exit 1
fi

volname=$1
pver=0.1.1

gluster volume status $volname detail>./vol-status.tmp 2>&1
volcheck=`cat ./vol-status.tmp|grep not|wc -l`
if [ $volcheck -gt 0 ]; then
  today=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  echo "                    Bad Brick(s) list ($pver)  "
  echo "                          $today $ctime "
  echo "======================================================================="
  echo "volume $volname does not exist, pls check the name of volume... "
  exit 1
fi

gluster volume status $volname detail|grep -E 'Brick|Online' > ./brick-$volname.tmp
#goodnum=`cat ./bricklist-$volname.tmp|grep Online|grep Y|wc -l`
#cat ./brick-$volname.tmp|grep -E 'Brick|N'|grep Brick > ./birck-bad-$volname.tmp
sed -n '/N/{g;1!p;};h' ./brick-$volname.tmp|awk '{print $3" "$4}' >./birck-bad-$volname.tmp

if [ ! -f ./brick-bad-$volname.tmp ]; then
  touch ./brick-bad-$volname.tmp
fi
badlist=`cat ./brick-bad-$volname.tmp|wc -l`
today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
echo "                    Bad Brick(s) list ($pver)  "
echo "                          $today $ctime "
echo "======================================================================="
if [ $badlist -gt 0 ]; then
  awk '{print $0}' ./birck-bad-$volname.tmp
else
  echo  "no bad brick(s) found in $volname..."
fi
rm -f ./brick-*.tmp
rm -f ./vol-*.tmp

#!/bin/bash
#author: chen dong @FSO
#Purposes: mount HD to /data directory, copy HD to /lustre/data and safely unmount HD
#Usage: ./lustre2hd.sh srcdir destdir year(4digits) monthday(4digits)
#Example: ./lustre2hd.sh /lustre/data  /data 2019 0420
#Changelog:
#         20190420 Version 0.1, first working script
#         20190421 Version 0.2, fixed minor errors, and using cp instead of rsync

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    umount $dev
    exit 1
}


echo " "
echo "===== Welcome to HD data Archiving System @FSO ====="
echo " "

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"

if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] ;then
  echo "Usage: ./lustre2hd.sh srcdir destdir year(4 digits) monthday(4 digits)"
  echo "Example: ./lustre2hd.sh   /lustre/data /data 2019 0420"
  exit 1
fi

out=$(lsblk -l|grep 'sd[b-z][1-9]' | awk '{print($1)}')
OLD_IFS="$IFS"
IFS=" "
hdlist=($out)
IFS="$OLD_IFS"
len1=0
echo "$today $ctime: Please select target drive to archiving..."
echo "Available devices:"
for i in ${hdlist[@]}
do
  echo "$len1: $i"
  let len1++
done

if [ $len1 -le 0 ];then
  echo "No devices available..."
  exit 1
fi 

echo "Pls select:"
read  uchoice
index=$(($uchoice+0))
if [[ "$index" -lt 0 ]] || [[ "$index">"$len1" ]];then
  echo "input error, pls try again!"
  exit 1
fi
s=0
for i in ${hdlist[@]}
do
  if [ "$s" -eq "$index" ];then
    hdname=$i
    break
  fi
  let s++
done
echo "$today $ctime: $hdname selected"

devpre="/dev/"
srcdir1=$1
destdir1=$2
ayear=$3
amonthday=$4
datatype="TIO"

destdir=${destdir1}${syssep}${ayear}${amonthday}${syssep}
srcdir=${srcdir1}${syssep}${ayear}${syssep}${ayear}${amonthday}${syssep}${datatype}${syssep}
dev=${devpre}${hdname}

mount -t ntfs-3g $dev $destdir1
if [ $? -ne 0 ];then
  echo "$today $ctime: mount $dev to $srcdir1 failed!"
  echo "                   please check!"
  exit 1
fi

ctime=`date --date='0 days ago' +%H:%M:%S`

dir1=${destdir1}${syssep}${ayear}${amonthday}
dir2=${destdir1}${syssep}${ayear}${amonthday}${syssep}${datatype}
if [ ! -d "$dir2" ]; then
  mkdir $dir1
  mkdir $dir2
else
    echo "$dir2 already exist!"
fi

if [ $? -ne 0 ];then
  echo "$today $ctime: create directory $dir3 failed!"
  echo "                   please check!"
  umount $dev
  exit 1
fi

ctime=`date --date='0 days ago' +%H:%M:%S`
echo " "
echo "$today $ctime: Archiving data from lustre to HD....."
echo "                   From: $srcdir"
echo "                   To  : $destdir @$dev"
echo "                   Please Waiting..."
echo "                   Copying..."
cp -r -u -v  $srcdir $destdir
if [ $? -ne 0 ];then
  echo "$today $ctime1: Archiving $dev to $srcdir failed!"
  echo "                   please check!"
  umount $dev
  exit 1
fi

ctime1=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime1: Changing Permissions of the DATA..."
chmod 777 -R $destdir
ctime1=`date --date='0 days ago' +%H:%M:%S`
if [ $? -ne 0 ];then
  echo "$today $ctime1: changing permissions in $srcdir failed!"
  echo "                   please check!"
  umount $dev
  exit 1
fi
umount $dev
srcsize=`du -sh $srcdir`
destsize=`du -sh $destdir`
ctime1=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime1: Succeeded in Archiving:"  
echo "                   From: $srcdir @$dev"
echo "                   To  : $destdir"
echo "            Source Size: $srcsize"
echo "              Dest Size: $destsize"
echo "Time used: $ctime to  $ctime1"
exit 0




#!/bin/bash
#author: chen dong @FSO
#Purposes: mount HD to /data directory, copy HD to /lustre/data and safely unmount HD
#Usage: ./hd2lustre.sh srcdir destdir year(in 4 digits)
#Example: ./hd2lustre.sh  /data  /lustre/data 2019
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

if [[ -z $1 ]] || [[ -z $2 ]] ;then
  echo "Usage: ./hdcopy.sh srcdir destdir year(in 4 digits)"
  echo "Example: ./hdcopy.sh /data  /lustre/data 2019"
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
srcdir=${srcdir1}${syssep}
destdir=${destdir1}${syssep}${ayear}${syssep}
echo "destdir is $destdir"
#echo "srcdir is $srcdir"
#read
#hdname=$(lsblk -l | grep sd|awk 'END{print $1}')
#echo $hdname
dev=${devpre}${hdname}
#echo $dev
mount -t ntfs-3g $dev $srcdir1
if [ $? -ne 0 ];then
  echo "$today $ctime: mount $dev to $srcdir1 failed!"
  echo "                   please check!"
  exit 1
fi


ctime=`date --date='0 days ago' +%H:%M:%S`
echo " "
echo "$today $ctime: Archiving data from HD to lustre....."
echo "                   From: $srcdir @$dev"
echo "                   To  : $destdir"
echo "                   Please Waiting..."
#read
cd $srcdir1
cp -r -u -v  * $destdir 

if [ $? -ne 0 ];then
  echo "$today $ctime1: Archiving $dev to $srcdir failed!"
  echo "                   please check!"
  umount $dev
  exit 1
fi

ctime1=`date --date='0 days ago' +%H:%M:%S`
chmod 777 -R $destdir
if [ $? -ne 0 ];then
  echo "$today $ctime1: chmod in $srcdir failed!"
  echo "                   please check!"
  umount $dev
  exit 1
fi
umount $dev
echo "$today $ctime1: Succeeded in Archiving  data@FSO!"
echo "Time used: $ctime to  $ctime1"
exit 0




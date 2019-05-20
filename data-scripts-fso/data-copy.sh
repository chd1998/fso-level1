#!/bin/bash
#author: chen dong @FSO
#Purposes: mount HD to a directory, copy from srcdir to destdir and safely unmount HD
#Usage: ./data-copy.sh srcdir destdir 
#Example: ./data-copy.sh /lustre/data/2019/20190518/TIO/12741/050530/ /data
#Changelog:
#         20190519 	Release 0.1	first working script

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    sleep 5
    umount $dev
    exit 1
}

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"

srcdir1=$1
destdir1=$2 

echo " "
echo "===== Welcome to data Archiving System @FSO ====="
echo "                data-copy.sh                     "
echo "          Release 0.1  20190519 16:45            "
echo " "

if [ $# -ne 2 ];then
  echo "Usage: ./data-copy.sh srcdir destdir"
  echo "Example: ./data-copy.sh /lustre/data/2019/20190518/TIO/12741/050530/ /data"
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
ctime=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime: $hdname selected"

devpre="/dev/"

tmpdir1=`echo ${srcdir1#/lustre/data}`
#echo "$tmpdir1"
#read
OLD_IFS="$IFS"
IFS="/"
tmpdir2=($tmpdir1)
IFS="$OLD_IFS"
destdir=${destdir1}${tmpdir1}
dev=${devpre}${hdname}

mount -t ntfs-3g $dev $destdir1
if [ $? -ne 0 ];then
  echo "$today $ctime: mount $dev to $srcdir1 failed!"
  echo "                   please check!"
  exit 1
fi

ctime=`date --date='0 days ago' +%H:%M:%S`
dir1=$destdir1

i=2
len=${#tmpdir2[@]}
let len1=len-1
while [ $i -lt $len ]
do
  #echo ${tmpdir2[$i]}
  dir1=${dir1}${syssep}${tmpdir2[$i]}
  if [ ! -d "$dir1" ]; then
    mkdir $dir1
    echo "$dir1 created!"
  else
    echo "$dir1 exists!"
  fi
  let i++
  if [ $i -eq $len1 ]; then
    dir2=$dir1
  fi
done
srcdir=$srcdir1
destdir=$dir2
#read
#dir1=$
#dir2=${dir1}${syssep}${datatype}${syssep}
#if [ ! -d "$dir2" ]; then
#  mkdir $dir1
#  mkdir $dir2
#else
#    echo "$dir2 already exist!"
#fi

if [ $? -ne 0 ];then
  echo "$today $ctime: create directory $dir1 failed!"
  echo "                   please check!"
  umount $dev
  exit 1
fi

srcsize=`du -sm $srcdir|awk '{print $1}'`
srcfilenum=`ls -lR $srcdir| grep "^-" | wc -l`

ctime=`date --date='0 days ago' +%H:%M:%S`
echo " "
echo "$today $ctime: Archiving data from lustre to HD....."
echo "                   From: $srcdir"
echo "                   To  : $destdir @ $dev"
echo "                   Please Waiting..."
echo "                   Copying..."
cp -ruvf  $srcdir $destdir
if [ $? -ne 0 ];then
  echo "$today $ctime1: Archiving $datatype data to $dev from $srcdir failed!"
  echo "                   please check!"
  umount $dev
  exit 1
fi

ctime1=`date --date='0 days ago' +%H:%M:%S`
#echo "$today $ctime1: Changing Permissions of the DATA..."
#chmod 777 -R -cfv $destdir
#ctime1=`date --date='0 days ago' +%H:%M:%S`
#if [ $? -ne 0 ];then
#  echo "$today $ctime1: changing permissions in $srcdir failed!"
#  echo "                   please check!"
#  umount $dev
#  exit 1
#fi
destfilenum=`ls -lR $destdir| grep "^-" | wc -l`
destsize=`du -sm $destdir|awk '{print $1}'`
umount $dev
ctime1=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime1: Succeeded in Archiving:"  
echo "                   From: $srcdir"
echo "                   To  : $destdir @ $dev"
echo "        Source File Num: $srcfilenum"
echo "            Source Size: $srcsize MB"
echo "          Dest File Num: $destfilenum"
echo "              Dest Size: $destsize MB"
echo "Time used: $ctime to  $ctime1"
exit 0




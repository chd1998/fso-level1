#!/bin/bash
#author: chen dong @FSO
#Purposes: mount HD to /data directory, copy HD to /lustre/data and safely unmount HD
#Usage: ./hd2lustre.sh srcdir destdir year(in 4 digits) datatype(TIO or HA)
#Example: ./hd2lustre.sh  /data  /lustre/data 2019 TIO
#Changelog:
#         20190420 release 0.1, first working script
#         20190421 release 0.2, fixed minor errors, and using cp instead of rsync
#         20190423 release 0.3, fixed error in reading parameters inputed
#         20190423 release 0.4, judge the srcdir is empty or not
#         20190424 release 0.5, fixed some error in copying 
#         20190424 release 0.6, add datatype as input to improve speed for chmoding
trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    umount $dev
    exit 1
}


echo " "
echo "===== Welcome to HD data Archiving System @FSO (Rev. 0.6 20190424 16:00) ====="
echo " "

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"
devpre="/dev/"

#if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] ;then
if [ $# -ne 4 ];then
  echo "Usage: ./hd2lustre.sh srcdir destdir year(in 4 digits) datatype(TIO or HA)"
  echo "Example: ./hd2lustre.sh /data  /lustre/data 2019 TIO"
  exit 1
fi

srcdir1=$1
destdir1=$2
ayear=$3
datatype=$4
srcdir=${srcdir1}${syssep}
destdir=${destdir1}${syssep}${ayear}${syssep}

# test the srcdir is empty or not
# if empty, mount the device
# else copy directly

stat=`ls $srcdir1|wc -w`
#stat less or equal 0 means srcdir is empty
if [ $stat -gt 0 ];then
  echo "$srcdir1 is not empty...."
  echo "please choose another mount point other then $srcdir1!"
  exit 1
fi

#searching for all available disk devices...
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

dev=${devpre}${hdname}
#echo $dev
mount -t ntfs-3g $dev $srcdir1
if [ $? -ne 0 ];then
  echo "$today $ctime: mount $dev to $srcdir1 failed!"
  echo "                   please check!"
  exit 1
fi
#mount device ended,start copying then

#dir=$(ls -l /data |awk '/^d/ {print $NF}')
#for i in $dir
#do
#  if [ ! -d "${destdir}${ayear}${syssep}${i}" ];then
#    mkdir ${destdir}${ayear}${syssep}${i}
#  fi
#done
srcsize=`du -sh $srcdir`
ctime=`date --date='0 days ago' +%H:%M:%S`
echo " "
echo "$today $ctime: Archiving data from HD to lustre....."
echo "                   From: $srcdir on $dev"
echo "                   To  : $destdir"
echo "$today $ctime: Copying...."
echo "                   Please Wait..."
#read

#cd $srcdir1
src=${srcdir}*
#echo "src= $src"
#read
cp -rufv  $src $destdir 

if [ $? -ne 0 ];then
  echo "$today $ctime1: Archiving $srcdir on $dev to $destdir failed!"
  echo "                   please check!"
  umount $dev
  exit 1
fi

ctime1=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime1: Copying Finished!....."
echo "$today $ctime1: Changing Permissions of Data....."
dir=$(ls -l /data |awk '/^d/ {print $NF}')
for i in $dir
do
  chmod 777 -R ${destdir}${i}${syssep}${datatype}
  
  #if [ $? -ne 0 ];then
  #  echo "$today $ctime1: chmod in  ${destdir}${i}  failed!"
  #  echo "                   please check!"
  #  umount $dev
  #  exit 1
  #fi
done
sleep 5s
umount $dev
#srcsize=`du -sh $srcdir`
destsize=`du -sh $destdir`
ctime1=`date --date='0 days ago' +%H:%M:%S`
echo "$today $ctime1: Succeeded in Archiving Data:"
echo "                   From: $srcdir on $dev"
echo "                   To  : $destdir"
echo "            Source Size: $srcsize"
echo "              Dest Size: $destsize"
echo "Time used: $ctime to  $ctime1"
exit 0




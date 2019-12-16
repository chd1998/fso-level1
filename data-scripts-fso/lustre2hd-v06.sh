#!/bin/bash
#author: chen dong @FSO
#Purposes: mount HD to /data directory, copy HD to /lustre/data and safely unmount HD
#Directory: /home/chd 
#Usage: ./lustre2hd-v06.sh srcdir mountpoint destdir 
#Example: ./lustre2hd-v06.sh /lustre/data/result/2017  /data /result
#Changelog:
#         20190420 	Release 0.1	first working script
#         20190421 	Release 0.2	fixed minor errors, and using cp instead of rsync
#         20190426 	Release 0.3	fixed minor display problems
# 		   	Release 0.4	sum the file num and size both in src and dest
#         20190625      Release 0.5     calculate speed of copying 
#         20191003      Release 0.6     copy defined dir to hd

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    umount $dev
    sleep 5
    exit 1
}

cyear=`date --date='0 days ago' +%Y`
today=`date --date='0 days ago' +%Y%m%d`
ctime=`date --date='0 days ago' +%H:%M:%S`
syssep="/"

echo " "
echo "====== Welcome to Lustre-->HD data Archiving System @ FSO ======"
echo "                Release 0.6  20191003 13:45                     "
echo "                                                                "
echo "             Copying data on lustre to Local HD                 "
echo "                                                                "
echo "                   $today    $ctime                             "
echo "================================================================"
echo " "


#if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] ;then
if [ $# -ne 3 ];then
  echo "Usage: ./lustre2hd-v06.sh srcdir mountpoint destdir"
  echo "Example: ./lustre2hd-v06.sh    /lustre/data/result/2017  /data /result"
  exit 1
fi

out=$(lsblk -l|grep 'sd[b-z][1-9]' | awk '{print($1)}')
OLD_IFS="$IFS"
IFS=" "
hdlist=($out)
IFS="$OLD_IFS"
len1=0
echo "Please select target drive to archiving..."
echo "Available devices:"
for i in ${hdlist[@]}
do
  echo "                 $len1: $i"
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
echo "                 $hdname selected"
echo "================================================================"

devpre="/dev/"
srcdir=$1
mountpoint=$2
destdir=$3
#ayear=$3
#amonthday=$4
#datatype=$5

#destdir=${destdir1}${syssep}${ayear}${amonthday}${syssep}
#srcdir=${srcdir1}${syssep}${ayear}${syssep}${ayear}${amonthday}${syssep}${datatype}${syssep}
dev=${devpre}${hdname}

mount -t ntfs-3g $dev $mountpoint
if [ $? -ne 0 ];then
  echo "$today $ctime: mount $dev to $mountpoint failed!"
  echo "                   please check!"
  exit 1
fi

ctime=`date --date='0 days ago' +%H:%M:%S`

#dir1=${destdir1}${syssep}${ayear}${amonthday}
#dir2=${dir1}${syssep}${datatype}${syssep}
destdir=$mountpoint$destdir
if [ ! -d "$destdir" ]; then
  mkdir -p $destdir
#  mkdir $dir2
else
    echo "$destdir already exist!"
fi

if [ $? -ne 0 ];then
  echo "$today $ctime: create dest directory $destdir failed!"
  echo "                   please check!"
  umount $dev
  sleep 5
  exit 1
fi

srcsize=`du -sm $srcdir|awk '{print $1}'`
srcfilenum=`ls -lR $srcdir| grep "^-" | wc -l`

ctime=`date --date='0 days ago' +%H:%M:%S`
echo "================================================================"
echo "$today $ctime: Archiving data from lustre to HD....."
echo "                   From: $srcdir"
echo "                   To  : $destdir @ $dev"
echo "                   Please Wait..."
echo "                   Copying..."
echo "================================================================"
echo " "
cp -ruvf  $srcdir $destdir
if [ $? -ne 0 ]; then
  ctime1=`date --date='0 days ago' +%H:%M:%S`
  echo "$today $ctime1: Archiving $datatype data to $dev from $srcdir failed!"
  echo "                   please check!"
  umount $dev
  sleep 5
  exit 1
fi

ctime1=`date --date='0 days ago' +%H:%M:%S`

t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`

destfilenum=`ls -lR $destdir| grep "^-" | wc -l`
destsize=`du -sm $destdir|awk '{print $1}'`

timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
if [ $timediff -eq 0 ]; then
  speed=0
else
  speed=`echo "$destsize $timediff"|awk '{print($1/$2)}'`
fi

umount $dev
sleep 5

ctime1=`date --date='0 days ago' +%H:%M:%S`
echo "================================================================"
echo "$today $ctime1: Succeeded in Archiving:"  
echo "                   From: $srcdir"
echo "                   To  : $destdir @ $dev"
echo "        Source File Num: $srcfilenum"
echo "                   Size: $srcsize MB"
echo "          Dest File Num: $destfilenum"
echo "                   Size: $destsize MB"
echo "                @ Speed: $speed MB/s"
echo "              Time Used: $timediff secs."
echo "                   From: $ctime "
echo "                     To: $ctime1"
echo "================================================================="
exit 0




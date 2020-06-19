#!/bin/bash
#author: chen dong @FSO
#Purposes: mount HD to /data directory, copy HD to /lustre/data and safely unmount HD
#Directory: /home/chd 
#Usage: ./lustre2hd.sh srcdir destdir year(4digits) monthday(4digits) datatype(TIO/HA)
#Example: ./lustre2hd.sh /lustre/data  /data 2019 0420 TIO
#Changelog:
#         20190420 	Release 0.1	first working script
#         20190421 	Release 0.2	fixed minor errors, and using cp instead of rsync
#         20190426 	Release 0.3	fixed minor display problems
# 		   	Release 0.4	sum the file num and size both in src and dest
#         20190625      Release 0.5     calculate speed of copying 

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    umount $dev
    sleep 5
    exit 1
}

cyear=`date  +%Y`
today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
syssep="/"

echo " "
echo "====== Welcome to Lustre-->HD data Archiving System @ FSO ======"
echo "                Release 0.5  20190625 20:45                     "
echo "                                                                "
echo "             Syncing data on lustre to Local HD                 "
echo "                                                                "
echo "                   $today    $ctime                             "
echo "================================================================"
echo " "


#if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] ;then
if [ $# -ne 5 ];then
  echo "Usage: ./lustre2hd.sh srcdir destdir year(4 digits) monthday(4 digits) datatype(TIO or HA)"
  echo "Example: ./lustre2hd.sh   /lustre/data /data 2019 0420 TIO"
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
ctime=`date  +%H:%M:%S`
echo "                 $hdname selected"
echo "================================================================"

devpre="/dev/"
srcdir1=$1
destdir1=$2
ayear=$3
amonthday=$4
datatype=$5

destdir=${destdir1}${syssep}${ayear}${amonthday}${syssep}
srcdir=${srcdir1}${syssep}${ayear}${syssep}${ayear}${amonthday}${syssep}${datatype}${syssep}
dev=${devpre}${hdname}

mount -t ntfs-3g $dev $destdir1
if [ $? -ne 0 ];then
  echo "$today $ctime: mount $dev to $srcdir1 failed!"
  echo "                   please check!"
  exit 1
fi

ctime=`date  +%H:%M:%S`

dir1=${destdir1}${syssep}${ayear}${amonthday}
dir2=${dir1}${syssep}${datatype}${syssep}
if [ ! -d "$dir2" ]; then
  mkdir $dir1
  mkdir $dir2
else
    echo "$dir2 already exist!"
fi

if [ $? -ne 0 ];then
  echo "$today $ctime: create directory $dir2 failed!"
  echo "                   please check!"
  umount $dev
  sleep 5
  exit 1
fi

srcsize=`du -sm $srcdir|awk '{print $1}'`
srcfilenum=`ls -lR $srcdir| grep "^-" | wc -l`

ctime=`date  +%H:%M:%S`
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
  ctime1=`date  +%H:%M:%S`
  echo "$today $ctime1: Archiving $datatype data to $dev from $srcdir failed!"
  echo "                   please check!"
  umount $dev
  sleep 5
  exit 1
fi

ctime1=`date  +%H:%M:%S`

t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`

#echo "$today $ctime1: Changing Permissions of the DATA..."
#chmod 777 -R -cfv $destdir
#ctime1=`date  +%H:%M:%S`
#if [ $? -ne 0 ];then
#  echo "$today $ctime1: changing permissions in $srcdir failed!"
#  echo "                   please check!"
#  umount $dev
#  exit 1
#fi
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
#srcsize=`du -sh $srcdir`
#destfilenum=`ls -lR $destdir| grep "^-" | wc -l`
#destsize=`du -sm $destdir`
ctime1=`date  +%H:%M:%S`
echo "================================================================"
echo "$today $ctime1: Succeeded in Archiving:"  
echo "                   From: $srcdir"
echo "                   To  : $destdir @ $dev"
echo "        Source File Num: $srcfilenum"
echo "            Source Size: $srcsize MB"
echo "          Dest File Num: $destfilenum"
echo "              Dest Size: $destsize MB"
echo "                  Speed: $speed MB/s"
echo "              Time Used: $timediff secs."
echo "              Time From: $ctime "
echo "                     To: $ctime1"
echo "================================================================="
exit 0




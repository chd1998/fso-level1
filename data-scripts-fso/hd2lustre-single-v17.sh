#!/bin/bash
#author: chen dong @FSO
#Purposes: mount HD to /data directory, copy HD to /lustre/data and safely unmount HD
#Usage: ./hd2lustre-single-v17.sh srcdir destdir year(4 digits) monthday(4 digits) datatype(TIO or HA)
#Example: ./hd2lustre-single-v17.sh  /data  /lustre/data 2019 0707 TIO
#Changelog:
#         20190420 Release 0.1, first working script
#         20190421 Release 0.2, fixed minor errors, and using cp instead of rsync
#         20190423 Release 0.3, fixed error in reading parameters inputed
#         20190423 Release 0.4, judge the srcdir is empty or not
#         20190424 Release 0.5, fixed some error in copying 
#         20190424 Release 0.6, add datatype as input to improve speed for chmoding
#         20190425 Release 0.7, add more info for chmod
#		               Release 0.8, sum of the data copied in MB
#                  Release 0.9, sum of file numbers both in src and dest
#	        20190625 Release 1.0, add speed info 
#         20190708 Release 1.1, add checking dest dir in year specified
#                               add datatype to destdir if missing in src
#                  Release 1.2, copy data of single day only
#         20190710 Release 1.4, copy process indicator added
#         20190711 Release 1.5, using tar & pv to copy data with all dirs  
#                  Release 1.6, revised for copying only single dir	
#         20191021 Release 1.7, modified input to fit requirement
#


waiting() {
  local pid="$1"
  taskname="$2"
  procing "$3" &
  local tmppid="$!"
  wait $pid
#�ָ���굽��󱣴��λ��
#  tput rc
#  tput ed
  wctime=`date  +%H:%M:%S`
  wtoday=`date  +%Y%m%d`
  echo "$wtoday $wctime: $2 Task Has Done!"
#  dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  echo "                   Finishing...."
#  msg "done" $boldblue
  kill -6 $tmppid >/dev/null 1>&2
  #echo "$dt1" > /home/chd/log/tmp
}

    #   ���������, С����
procing() {
  trap 'exit 0;' 6
  tput ed
  while [ 1 ]
  do
    sleep 1
    ptoday=`date  +%Y%m%d`
    pctime=`date  +%H:%M:%S`
    echo "$ptoday $pctime: $1, Please Wait...   "
  done
}

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    umount $dev
    exit 1
}

if [ $# -ne 3 ];then
  echo "Usage: ./hd2lustre-single-v17.sh srcpre destpre destdir"
  echo "Example: ./hd2lustre-single-v17.sh /data  /lustre/data/2019 /20191020/TIO/CH/055332"
  exit 1
fi

cyear=`date  +%Y`
today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
syssep="/"
devpre="/dev/"

echo " "
echo " "
echo "====== Welcome to HD-->Lustre data Archiving System @FSO ======"
echo "                 Release 1.7 20191021 18:02                    "
echo "                                                               "
echo "              Syncing data from local HD to Lustre             "
echo "                                                               "
echo "                     $today   $ctime                           "
echo "                                                               " 
echo "==============================================================="
echo " "

srcdir1=$1
destdir1=$2
destdir2=$3
#ayear=$3
#amonthday=$4
datatype=$3
srcdir=${srcdir1}${destdir2}
destdir=${destdir1}${destdir2}

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
ctime=`date  +%H:%M:%S`
echo "$today $ctime: $hdname selected"

dev=${devpre}${hdname}
#echo $dev
mount -t ntfs-3g $dev $srcdir1
if [ $? -ne 0 ];then
  echo "$today $ctime: mount $dev to $srcdir1 failed!"
  echo "                   please check!"
  exit 1
fi
echo "$today $ctime: Calculating size and file number in $srcdir..."
srcsize=`du -sm $src|awk '{print $1}'`
srcfilenum=`ls -lR $src| grep "^-" | wc -l`
#mount device ended,start copying then

destsizetmp=0
destfilenumtmp=0
destsizetotal=0
destfilenumtotal=0
timetotal=0
ctime=`date  +%H:%M:%S`
#t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t1=`date +%s`

#create destdir with datatype is missing
#if [ ! -d "${destdir}" ];then
#  mkdir -p -m 777 ${destdir}
#fi
src=${srcdir1}${destdir2}
dest=${destdir1}${destdir2}
#dest=${destdir}${ayear}${amonthday}
#src=${srcdir}${ayear}${amonthday}

if [ ! -d "${src}" ];then
  echo "$src doesn't exist, please check!"
  exit 1
fi

if [ ! -d "${dest}" ];then
  mkdir -p -m 777 ${dest}
fi

ctime1=`date  +%H:%M:%S`
echo " "
echo "==============================================================="
echo "$today $ctime1: Archiving @datatype data from HD to lustre....."
echo "                   From: $src on $dev"
echo "                   To  : $dest"
#echo "$today $ctime1: Copying...."
#echo "                   Please Wait..."
echo "==============================================================="

cd $src
cp -ruf  . $dest >/dev/null 2>&1 &
#tar cf - . | pv -s $(du -sb "$src" | cut -f1) | tar xf - -C "$dest"
waiting "$!" "$datatype Data Copying" "Copying $datatype Data"

if [ $? -ne 0 ];then
  ctime1=`date  +%H:%M:%S`
  echo "$today $ctime1: Archiving $src on $dev to $dest failed!"
  echo "                   please check!"
  umount $dev
  exit 1
fi

ctime1=`date  +%H:%M:%S`
#t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
t2=`date +%s`

destsize=`du -sm $dest|awk '{print $1}'`
destfilenum=`ls -lR $dest| grep "^-" | wc -l`
timetotal=`echo "$t1 $t2"|awk '{print($2-$1)}'`
echo "$today $ctime1: Copying From $src To $dest Finished!....."
  
#speed of copy 
ctime2=`date  +%H:%M:%S`

if [ $timetotal -eq 0 ]; then
	speed=0
fi
speed=`echo "$destsize $timetotal"|awk '{print($1/$2)}'`
today0=`date  +%Y%m%d`

echo "==============================================================="
echo "$today0 $ctime1: Succeeded in Archiving Data:"
echo "                   From: $srcdir on $dev"
echo "                   To  : $destdir"
echo "        Source File Num: $srcfilenum"
echo "            Source Size: $srcsize MB"
echo "          Dest File Num: $destfilenum"
echo "              Dest Size: $destsize MB"
echo "                  Speed: $speed MB/s"
echo "              Time Used: $timetotal secs."
echo "              Time From: $today $ctime "
echo "	             To: $today0 $ctime2"
echo "==============================================================="
echo "$today0 $ctime2: Umounting $srcdir1, please wait...."
cd /home/chd
sleep 5
ctime3=`date  +%H:%M:%S`
umount $srcdir1
if [ $? -ne 0 ];then
  echo "$today0 $ctime3: umount $srcdir1 failed!"
  echo "                   please check!"
  exit 1
else
  ctime3=`date  +%H:%M:%S`
  echo "$today0 $ctime3: $srcdir1 umounted"
  exit 0
fi

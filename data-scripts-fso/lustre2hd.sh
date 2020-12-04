#!/bin/bash
#author: chen dong @FSO
#Purposes: mount HD to /data directory, copy HD to /lustre/data and safely unmount HD
#Directory: /home/chd 
#Usage: ./lustre2hd.sh srcdir destdir syear smonthday eyear emonthday datatype(TIO/HA)
#Example: ./lustre2hd.sh   /lustre/data /data 2020 1129 2020 1130 TIO
#Changelog:
#         20190420 	Release 0.1.0	    first working script
#         20190421 	Release 0.2.0	    fixed minor errors, and using cp instead of rsync
#         20190426 	Release 0.3.0	    fixed minor display problems
# 		   	          Release 0.4.0	    sum the file num and size both in src and dest
#         20190625  Release 0.5.0     calculate speed of copying 
#         20201129  Release 0.5.1     add time span to copy
#         20201130  Release 0.5.2     add progress info to copy 

trap 'onCtrlC' INT
function onCtrlC(){
    echo "Ctrl-C Captured! "
    echo "Breaking..."
    wctime=`date  +%H:%M:%S`
    wtoday=`date  +%Y%m%d`
    if [ -n "$dev" ]; then
    	umount $dev
      if [ $? -ne 0 ];then
        echo "$wtoday $wctime: umount $dev to $destdir1 failed!"
        echo "                   please check!"
      fi
    fi
    sleep 5
    exit 1
}

waiting() {
  local pid="$1"
  taskname="$2"
  procing "$3" &
  local tmppid="$!"
  wait $pid
  #sleep 1
  tput rc
  tput ed
  wctime=`date  +%H:%M:%S`
  wtoday=`date  +%Y%m%d`
  #echo "$wtoday $wctime : $2 Task Has Done!"
#  dt1=`echo $wctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  dt1=`date +%s`
#  echo "                   Finishing..."
  kill -6 $tmppid >/dev/null 1>&2
  echo "$dt1" > /home/chd/log/dtmp
}

procing() {
  trap 'tput ed;tput rc;exit 0;' 6
  tput ed
  while [ 1 ]
  do
    for j in '-' '\\' '|' '/'
    do
      tput sc
      ptoday=`date  +%Y%m%d`
      pctime=`date  +%H:%M:%S`
      echo -ne  "$ptoday $pctime : $1...   $j"
      sleep 0.2
      tput rc
    done
  done
}

cyear=`date  +%Y`
today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
syssep="/"
pver=0.5.2

echo " "
echo "=============== Welcome to Data System @FSO ===================="
echo "                      Release $pver                             "
echo "                                                                "
echo "             Syncing data on lustre to Local HD                 "
echo "                                                                "
echo "                   $today    $ctime                             "
echo "================================================================"
echo " "


#if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[ -z $4 ]] ;then
if [ $# -ne 7 ];then
  echo "Usage: ./lustre2hd.sh srcdir destdir syear smonthday eyear emonthday datatype(TIO or HA)"
  echo "Example: ./lustre2hd.sh   /lustre/data /data 2020 1129 2020 1130 TIO"
  exit 1
fi
devpre="/dev/"
srcdir1=$1
destdir1=$2
ayear=$3
amonthday=$4
byear=$5
bmonthday=$6
datatype=$7

out=$(lsblk -l|grep 'sd[b-z][1-9]' | awk '{print($1)}')
OLD_IFS="$IFS"
IFS=" "
hdlist=($out)
IFS="$OLD_IFS"
len1=0
echo "Please select target drive to archive..."
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
#mount hd to destdir1
dev=${devpre}${hdname}
mount -t ntfs-3g $dev $destdir1
if [ $? -ne 0 ];then
  echo "$today $ctime: mount $dev to $destdir1 failed!"
  echo "                   please check!"
  exit 1
fi

sdate=$ayear$amonthday
edate=$byear$bmonthday
checkdays=$((($(date +%s -d $edate) - $(date +%s -d $sdate))/86400));
totaldays=`echo $checkdays 1|awk '{print($1+$2)}'`
today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
today0=`date  +%Y%m%d`
ctime0=`date  +%H:%M:%S`
i=0
t0=`date +%s`
srcfntotal=0
srcfstotal=0
destfntotal=0
destfstotal=0

while [ $i -le $checkdays ]
do
  checkdate=`date +%Y%m%d -d "+$i days $sdate"`
  checkyear=${checkdate:0:4}
  checkmonthday=${checkdate:4:4}
	today=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  destdir=${destdir1}${syssep}${checkyear}${checkmonthday}${syssep}
  srcdir=${srcdir1}${syssep}${checkyear}${syssep}${checkyear}${checkmonthday}${syssep}${datatype}${syssep}
  dir1=${destdir1}${syssep}${checkyear}${checkmonthday}
  dir2=${dir1}${syssep}${datatype}${syssep}
  if [ ! -d "$dir2" ]; then
    mkdir $dir1
    mkdir $dir2
    if [ $? -ne 0 ];then
<<<<<<< HEAD
      today=`date  +%Y%m%d`
      ctime=`date  +%H:%M:%S`
=======
<<<<<<< HEAD
      today=`date  +%Y%m%d`
      ctime=`date  +%H:%M:%S`
=======
>>>>>>> cf86901cd857d36cf95ea8c944643c4cefa41f7e
>>>>>>> 36536c6f4cb3eb0b5837cf8c683b001edd0d2edf
      echo "$today $ctime : create directory $dir2 failed!"
      echo "                   please check!"
      if [ -n "$dev" ]; then
        umount $dev
        if [ $? -ne 0 ];then
          today=`date  +%Y%m%d`
          ctime=`date  +%H:%M:%S`
          echo "$today $ctime: umount $dev from $destdir1 failed!"
          echo "                   please check!"
        fi
      fi
      sleep 5
      exit 1
    fi
  else
<<<<<<< HEAD
    echo "  "
    echo "$today $ctime: $dir2 already exist!"
=======
<<<<<<< HEAD
    echo "  "
    echo "$today $ctime: $dir2 already exist!"
=======
    echo "$dir2 already exist!"
>>>>>>> cf86901cd857d36cf95ea8c944643c4cefa41f7e
>>>>>>> 36536c6f4cb3eb0b5837cf8c683b001edd0d2edf
  fi

  srcsize=`du -sm $srcdir|awk '{print $1}'`
  srcfilenum=`ls -lR $srcdir| grep "^-" | wc -l`
  srcfntotal=`echo $srcfntotal $srcfilenum|awk '{print($1+$2)}'`
  srcfstotal=`echo $srcfstotal $srcsize|awk '{print($1+$2)}'`
  today=`date  +%Y%m%d`
  ctime=`date  +%H:%M:%S`
  echo " "
  echo "================================================================"
<<<<<<< HEAD
=======
<<<<<<< HEAD
>>>>>>> 36536c6f4cb3eb0b5837cf8c683b001edd0d2edf
  echo "$today $ctime : Archiving data from lustre to HD....."
  echo "                    From $srcdir"
  echo "                    To   $dir1 @$dev"
  echo "                    Please Wait..."
  cp -runf  $srcdir $destdir &
<<<<<<< HEAD
  waiting "$!" " $datatype Data Archiving of $checkyear$checkdate from $srcdir to $dir1 @$dev" "Archiving $datatype Data of $checkyear$checkdate from $srcdir to $dir1 @$dev"
  
=======
  waiting "$!" " $datatype Data Archiving of $checkyear$checkdate from $srcdir to $dir1 @$dev" "Archiving $datatype Data of $checkyear$checkdate from $srcdir to $dir1 @$dev"
  
=======
  echo "$today $ctime: Archiving data from lustre to HD....."
  echo "                   From: $srcdir"
  echo "                   To  : $dir1 @$dev"
  echo "                   Please Wait..."
  echo "================================================================"
  cp -rf  $srcdir $destdir &
  waiting "$!" " $datatype Data Archiving of $checkyear$checkdate from $srcdir to $dir1 @$dev" "Archiving $datatype Data of $checkyear$checkdate from $srcdir to $dir1 @$dev"
>>>>>>> cf86901cd857d36cf95ea8c944643c4cefa41f7e
>>>>>>> 36536c6f4cb3eb0b5837cf8c683b001edd0d2edf
  if [ $? -ne 0 ]; then
    today=`date  +%Y%m%d`
    ctime=`date  +%H:%M:%S`
    echo "$today $ctime: Archiving $datatype data to $dir1 @$dev from $srcdir failed!"
    echo "                   please check!"
    if [ -n "$dev" ]; then
      umount $dev
      if [ $? -ne 0 ];then
        today=`date  +%Y%m%d`
        ctime=`date  +%H:%M:%S`
        echo "$today $ctime: umount $dev from $destdir1 failed!"
        echo "                   please check!"
      fi
    fi 
    sleep 5
    exit 1
  fi
  ctime1=`date  +%H:%M:%S`

  t1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
  t2=`echo $ctime1|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`

  destfilenum=`ls -lR $destdir| grep "^-" | wc -l`
  destsize=`du -sm $destdir|awk '{print $1}'`
  destfntotal=`echo $destfntotal $destfilenum|awk '{print($1+$2)}'`
  destfstotal=`echo $destfstotal $destsize|awk '{print($1+$2)}'`

  timediff=`echo "$t1 $t2"|awk '{print($2-$1)}'`
  if [ $timediff -le 0 ]; then
    timediff=0
    destsize=0
    speed=0
  else
    speed=`echo "$destsize $timediff"|awk '{print($1/$2)}'`
  fi
  let i++
  echo "                   $datatype data @$checkyear$checkmonthday  Copied..."
  echo "                   $i of $totaldays day(s) Processed..."
  echo "================================================================"
done

if [ -n "$dev" ]; then  
  umount $dev
  if [ $? -ne 0 ];then
    today=`date  +%Y%m%d`
    ctime=`date  +%H:%M:%S`
    echo "$today $ctime: umount $dev from $destdir1 failed!"
    echo "                   please check!"
  fi
fi
#srcsize=`du -sh $srcdir`
#destfilenum=`ls -lR $destdir| grep "^-" | wc -l`
#destsize=`du -sm $destdir`
today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
#echo "================================================================"
<<<<<<< HEAD
echo "$today $ctime : Succeeded in Archiving $datatype data from $sdate to $edate"
=======
echo "$today $ctime : Succeeded in Archiving:"  
echo "             From : $today0 $ctime0"
echo "               To : $today $ctime"
>>>>>>> 36536c6f4cb3eb0b5837cf8c683b001edd0d2edf
echo "     Src File No. : $srcfntotal"
echo "             Size : $srcfstotal"
echo "    Dest File No. : $destfntotal"
echo "             Size : $destfstotal"
<<<<<<< HEAD
echo "             From : $today0 $ctime0"
echo "               To : $today $ctime"
=======
<<<<<<< HEAD
echo "               in : $timediff secs. "
=======
>>>>>>> 36536c6f4cb3eb0b5837cf8c683b001edd0d2edf
echo "             Used : $timediff secs. "
>>>>>>> cf86901cd857d36cf95ea8c944643c4cefa41f7e
echo "================================================================="
exit 0
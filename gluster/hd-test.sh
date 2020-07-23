#!/bin/bash
# ./hd-test.sh  1000 100K 100
if [ $# -ne 4 ];then
  echo "usage: ./hd-test.sh  loop blocksize blockcount dest"
  echo "./hd-test.sh  1000 100K 100 /data"
  exit 0
fi
start=`date +%s`
blocksize=$2
blockcount=$3
loop=$1
for ((i=1;i<=$1;i++));
do
    (
        echo "Writing to $4...$i"
        dd if=/dev/zero bs=$2 count=$3 of=$4/$i-test.dat conv=fdatasync
    )&
done
wait
end=`date +%s`
today=`date +%Y%m%d`
ctime=`date +%H:%M:%S`
timeused=`echo "$end $start"|awk '{print($1-$2)}'`
writesize=`echo "$blocksize $blockcount $loop"|awk '{print($3*$1*$2/1000)}'`
filesize=`echo "$blocksize $blockcount "|awk '{print($1*$2/1000)}'`
speed=`echo "$blocksize $blockcount $loop $timeused"|awk '{print(($1*$2*$3)/($4*1000))}'`
echo "$today $ctime : Writing parallelly in $1 processes to $4" 
echo "       Parameters : blocksize=$2 blockcount=$3 filesize=$filesize MB "
echo "       Total Size : $writesize MB"
echo "        Time Used : $timeused secs."
echo "      Write Speed : $speed MB/s"
rm -f $4/*.dat &
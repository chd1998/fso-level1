#!/bin/bash
out=$(lsblk -l|grep 'sd[b-z][1-9]' | awk '{print($1)}')
OLD_IFS="$IFS"
IFS=" "
hdlist=($out)
IFS="$OLD_IFS"
len1=0
echo "please select target drive to archiving..."
for i in ${hdlist[@]}
do 
  echo "$len1: $i"
  let len1++
done
if [ "$len1" -le 0 ];then
  echo "No device available..."
  exit 1
fi
echo "pls input:"
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
    dev=$i
    break
  fi
  let s++
done
echo "$dev selected"

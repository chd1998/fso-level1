#!/bin/bash
cyear=`date  +%Y`
dir=$1
dir1="/data"
tmp=`echo ${dir#/lustre/data}`
OLD_IFS="$IFS"
IFS="/"
array=($tmp)
IFS="$OLD_IFS"
i=2 
while [ $i -lt ${#array[@]} ]
do
   dir1=${dir1}"/"${array[$i]}
   echo $dir1
   let i++
done


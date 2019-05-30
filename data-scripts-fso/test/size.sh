#!/bin/bash

n2=$(cat number.dat)
s3=$(cat size.dat)

number=40
size=1600

speedofn=`echo "$number $n2"|awk '{print($1-$2)}'`
speedofs=`echo "$size $s3"|awk '{print($1-$2)}'`

echo $speedofn
echo $speedofs


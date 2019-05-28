#!/bin/bash
s1=$(du -sh /home/chd| awk '{print $1}')
s2=$(du -sh /home/qy| awk '{print $1}')
a=($s1 $s2)
for s in ${a[@]}
do 
  echo "$s"
done

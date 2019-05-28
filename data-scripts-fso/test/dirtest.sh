#!/bin/bash
#du -sh /home/chd| awk '{print $1}'
destdir="/lustre/data/"
dir=$(ls -l /lustre/data/2019/20190422/TIO |awk '/^d/ {print $NF}')
for i in $dir
do
  echo " ${destdir}${i}"

done

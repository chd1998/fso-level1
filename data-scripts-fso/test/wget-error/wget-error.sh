#!/bin/sh
cat test.list|awk '{print $1}'|cut -d '/' -f 5-9 > dir.list
cat test.list|awk '{print $1}'|cut -d '/' -f 10 > file.list
#do 
#  echo $dir1
#  echo $file1
#done

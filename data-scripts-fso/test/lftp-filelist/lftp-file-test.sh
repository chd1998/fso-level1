#!/bin/bash
find /lustre/data/2019/20190907/TIO/  -type f  | cut -d '/' -f 5-10 > local-filelist
lftp ftp://tio:ynao246135@192.168.111.120  -e "find /20190907/TIO;exit"| grep fits|cut -d '/' -f 1-9 > remote-filelist
sort local-filelist -o local-filelist
sort remote-filelist -o remote-filelist
for line in $(cat local-filelist);
do 
  line=/$line
  echo $line >> tmp-list
done
mv tmp-list local-filelist
comm -3 --nocheck-order local-filelist remote-filelist > difflist


#!/bin/sh
echo "getting file list for re-syncing..."
cat test.list|awk '{print $1}'|cut -d '/' -f 5-10 > rfile.list
#cat test.list|awk '{print $1}'|cut -d '/' -f 10 > file.list
for line in $(<rfile.list);
do 
  echo "ftp://tio:ynao246135@192.168.111.120:21/$line" > ftpfile.list
done
echo "Runing wget..."
echo " "
wget -q -i ftpfile.list
echo "Done!"

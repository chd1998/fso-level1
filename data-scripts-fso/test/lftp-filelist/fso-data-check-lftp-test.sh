#!/bin/bash
#check the size of dest dir every 10 minutes via cron, and export total error list in file
#usage: ./fso-data-check-lftp-xx.sh ip port user passwd datatype fileformat"
#example: ./fso-data-check-lftp-xx.sh 192.168.111.120 21 tio ynao246135 TIO fits"
#example: ./fso-data-check-lftp-xx.sh 192.168.111.122 21 ha ynao246135 HA fits"
#press ctrl-c to break the script
#change log:
#           Release 20190721-0931: First working prototype

server=$1
port=$2
user=$3
passwd=$4
year=$5
monthday=$6
datatype=$7
fileformat=$8

#cd /home/chd/
homepre="/home/chd"
syssep="/"

localdir=/lustre/data/$year/$year$monthday/$datatype
remotedir=/$year$monthday/$datatype

locallist=/home/chd/log/locallist
remotelist=/home/chd/log/remotelist

find $localdir/ -type f -name '$fileformat' > $locallist

#getting remote file list
server1=ftp://$user:$passwd@$server
echo "Getting remote file(s) info..."
lftp $server1 -e "find $remotedir;quit"| grep $fileformat|cut -d '/' -f 1-9 > $remotelist
sort $remotelist -o $remotelist

#add / to locallist
for line in $(cat $locallist);
do
  line=/$line
  echo $line >> tmplist
done
mv tmplist $locallist

sort $locallist -o $locallist

comm -3 $remotelist $locallist > difflist


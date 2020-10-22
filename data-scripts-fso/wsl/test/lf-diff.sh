#!/bin/bash

if [ $# -ne 7 ];then
  echo "usage: ./lf-diff.sh server user password localdrive year monthday datatype"
  echo "example: ./lf-diff.sh 192.168.111.122 ha ynao246135 f 2019 1124 HA"
  exit 0
fi

$server=$1
$user=$2
$password=$3
$localdrive=$4
$year=$5
$monthday=$6
$datatype=$7


echo "getting local $datatype file(s) list..."
find /cygdrive/$localdrive/$year$monthday/$datatype/ -type f -name '*.fits' |cut -d '/' -f 4-11 > ./local

lftp ftp://$user:$password@$server -e "find /$year$monthday/$datatype;quit"| grep fits|cut -d '/' -f 1-9 > remote

touch ./localtmplist
for line in $(cat ./local);
do
  line=/$line
  echo $line >> ./localtmplist
done
mv ./localtmplist ./local
awk 'NR==FNR{ a[$1]=$1 } NR>FNR{ if(a[$1] == ""){ print $1}}' local remote > diff

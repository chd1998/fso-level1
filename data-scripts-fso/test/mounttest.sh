#!/bin/bash 

stat=`ls /data|wc -w`

if [ $stat -gt 0  ];then
  echo "not empty"
else
  echo "is empty"
fi
echo $stat

#!/bin/sh
mypid=$(pidof curlftpfs)
if [ -z "$mypid" ];then
  echo "not found"
else
  echo "found!"
fi

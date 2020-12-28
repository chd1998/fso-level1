#!/bin/bash

if [ $# -ne 2 ];then
  echo "Usage: ./top-n-size-list.sh destdir n(top n listed)"
  echo "Example: ./top-n-size-list.sh  / 10"
  exit 1
fi
find $1 -path "*proc*"  -prune -false  -o  -type f -name  "*"  -print0 | xargs -0 du -h | sort -rh | head -n 10
#find $1 -type d \( -name *proc* -o -name */run/user* \) -prune -false  -o  -type f -name  "*"  -print0 | xargs -0 du -h | sort -rh | head -n $2

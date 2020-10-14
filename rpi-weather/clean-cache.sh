#!/bin/bash
#lsof -e /run/user/1000/gvfs -n /fso-cache |grep deleted|awk '{print $2}'|xargs kill -9
x=()
for a in $(mount | cut -d' ' -f3) 
do 
  test -e "$a" || x+=("-e$a")
done
lsof "${x[@]}"  /fso-cache/ |grep deleted|awk '{print $2}'|xargs kill -9
rm -f /fso-cache/*

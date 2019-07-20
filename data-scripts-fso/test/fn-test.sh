#!/bin/sh
fn=$(cat  ../log/TIO-20190718-192.168.111.120-filenumber.dat | awk '{print $3}')
if [ -z $fn ]; then
  fn=0
fi
echo $fn

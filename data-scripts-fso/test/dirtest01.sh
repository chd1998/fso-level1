#!/bin/bash
#du -sh /home/chd| awk '{print $1}'
destdir="/data"

currd=`ls $destdir/.|awk -F" " '{print $2}'`
echo $currd

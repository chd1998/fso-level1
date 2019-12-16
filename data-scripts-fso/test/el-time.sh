#!/bin/bash
ctime=`date  "+%Y-%m-%d %H:%M:%S"`
st1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`

ctime2=`date -d "+1day" "+%Y-%m-%d %H:%M:%S"`
st2=`echo $ctime2|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
stdiff=`echo "$st1 $st2"|awk '{print($2-$1)}'`

echo " Total Time Used : $stdiff secs."


#!/bin/bash
du -sm /home| awk '{print $1}' > sum.log
du -sm /root | awk '{print $1}' >> sum.log
mystr=sum.log
myunit=`cat sum.log | awk '{print substr($0,length($1),1)}'`
mysum=`cat sum.log | awk '{a+= $0}END{print a}'`
echo "${mysum}${myunit}"

#!/bin/bash
du -sm /home/chd| awk '{print $1}' > sum.log
du -sm /home/qy| awk '{print $1}' >> sum.log

cat sum.log | awk '{print $1}'
cat sum.log | awk '{a+= $0}END{print a}'

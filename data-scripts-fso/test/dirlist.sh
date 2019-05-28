#!/bin/bash
dir=$(ls -l /data |awk '/^d/ {print $NF}')
for i in $dir
do
    echo $i
done   

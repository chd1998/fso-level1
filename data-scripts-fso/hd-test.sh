#!/bin/bash
# ./hd-test.sh  1000 100K 100
for ((i=1;i<=$1;i++));
do
    (
        echo "Writing to GlusterFS...$i"
        dd if=/dev/zero bs=$2 count=$3 of=$i-test.dat
    )&
done
wait

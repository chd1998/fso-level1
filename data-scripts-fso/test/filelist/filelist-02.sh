#!/bin/sh

grep -vwf b.txt a.txt>c.txt
cp c.txt d.txt
for line in $(cat c.txt);
do 
  echo $line
  echo $line > tmp.txt
  grep -vwf tmp.txt c.txt>c.txt
done

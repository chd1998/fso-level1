#!/bin/sh

grep -vFf b.txt a.txt>c.txt
cp c.txt d.txt
for line in $(cat c.txt);
do 
  echo $line
  echo $line > tmp.txt
  grep -vFf tmp.txt c.txt>c.txt
done

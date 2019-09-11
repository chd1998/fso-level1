#!/bin/bash
#touch mytest.txt
echo "10" > mytest.txt
x=$(cat mytest.txt)
if [[ $x -ne 0 ]];then
  echo "not equal to zero!"
else
  echo "equal to zero!"
fi

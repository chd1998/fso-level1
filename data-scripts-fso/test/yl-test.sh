#!/bin/bash

str1="H_XXXXXXB-1_4"
str2=${str1#*-}

echo $str2

if [ $str2 == "1_4" ];then
echo "equal"
fi

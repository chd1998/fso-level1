#!/bin/bash
echo -n "pls input an integer: "
read num
if [[ $num =~ ^-?[0-9]+$ ]]; then
  echo "$num is a number"
else
  echo "$num is not a number"
fi

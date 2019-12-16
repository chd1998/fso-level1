#!/bin/bash
str="cygdrive/f"
if [[ $str != /* ]]; then
  echo "no"
else
  echo "yes"
fi

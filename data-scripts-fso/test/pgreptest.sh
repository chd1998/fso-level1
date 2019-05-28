#!/bin/bash

#pgrep -fo $1
#ps -eo pid | awk '{print $1}'|grep $1 
ps x|grep $1|grep -v grep|awk '{print $1}'

#!/bin/bash
cyear=`date --date='0 days ago' +%Y`
dir=$1
echo ${dir#/lustre/data/$cyear}

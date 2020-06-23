#!/bin/bash
cyear=`date  +%Y`
dir=$1
echo ${dir#/lustre/data/$cyear}

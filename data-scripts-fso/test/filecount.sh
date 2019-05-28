#!/bin/bash
#count the number of files under a directory including subdir
ls -lR /lustre/data/2019/20190426/TIO | grep "^-" | wc -l

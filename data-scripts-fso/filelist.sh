#!/bin/bash

find $1 -path "*proc*" -o -path "*lustre*" -prune -false  -o  -type f -name  "*"  -print0 | xargs -0 du -h | sort -rh | head -n 10

#!/bin/bash
curh=`date  +%H%M`
echo "$curh"
if [[ $curh -gt 2250 ]]; then
	echo "great!"
else
	echo "less!"
fi



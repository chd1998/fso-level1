#!/bin/bash
function dirsize()
{
  echo `du -sm $1|awk '{print $1}'`
  #return $sdata
}

cdata=$(dirsize $1)
echo $cdata 
#echo $?


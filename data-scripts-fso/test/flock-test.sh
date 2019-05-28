#!/bin/bash
{
flock -n 3
[ $? -eq 1 ] && { echo fail; exit; }
echo $$
sleep 10
} 3<>mylockfile

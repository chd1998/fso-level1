#!/bin/bash
for ip in $1.{1..254}
do
    (
        ping $ip -c2 &> /dev/null
        if [ $? -eq 0 ];
        then
            echo "$ip 在线"
        fi
    )&
done
wait

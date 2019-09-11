#!/bin/sh
./waittest-02.sh & 
wait $!
echo $?

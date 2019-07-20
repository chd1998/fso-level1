#!/bin/sh
for i in {1..15}; do
  (echo "$i";sleep 10 ; exit $RANDOM) &
done

for i in {1..15}; do
  wait %$i
  echo $?
done

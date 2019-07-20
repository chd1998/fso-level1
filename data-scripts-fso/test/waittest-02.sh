#!/bin/sh
for i in {1..15}; do
  (echo "$i";sleep 10; exit $RANDOM) &
done

jobnumber=$(jobs -p | wc -l)
echo "$jobnumber processes started!"

j=1
while [ $j -lt $jobnumber ]; do
  wait %$j
  echo $?
  if [ $? -ne 0 ]; then
    echo "exited abnormally!"
  fi 
  ((j++))
done
echo "$jobnumber processes done"

#!/bin/sh

/home/chd/fso-data-check-cron.sh /lustre/data/$(date +\%Y)/$(date +\%Y\%m\%d)/$datatype $datatype $fileformat $stdsize >> /home/chd/log/check-$datatype-size.log &
wait %$?
echo $?
for i in {1..15}; do
  (echo "$i";sleep 10; exit $RANDOM) &
done

echo "$jobnumber processes done"

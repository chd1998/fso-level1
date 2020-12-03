#!/bin/sh
echo "Starting data log analysis..."
cent=`find /lustre/data/2020/20201202/HA/ -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*" -o -name "*FLAT*" -prune -false  -o  -type d -name  "CENT*" -print|awk -F "/" '{print $NF}'|uniq`
boff=`find /lustre/data/2020/20201202/HA/ -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*" -o -name "*FLAT*" -prune -false  -o  -type d -name  "B*" -print|awk -F "/" '{print $NF}'|uniq`
roff=`find /lustre/data/2020/20201202/HA/ -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*" -o -name "*FLAT*" -prune -false  -o  -type d -name  "R*" -print|awk -F "/" '{print $NF}'|uniq`
find /lustre/data/2020/20201202/HA/ -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "CENT*" -print>clist
find /lustre/data/2020/20201202/HA/ -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "B*" -print>blist
find /lustre/data/2020/20201202/HA/ -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "R*" -print>rlist
echo " HA Data">logtmp
echo "$cent : "
echo "$cent : ">>logtmp
for line in $(cat clist);
  do
    cstime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "CENT*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
    cetime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "CENT*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
    echo " $line    $cstime         $cetime"
    echo " $line    $cstime         $cetime">>logtmp
done 
echo "$boff : "
echo "$boff : ">>logtmp
for line in $(cat blist);
  do
    bstime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "B*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
    betime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "B*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
    echo " $line    $bstime         $betime"
    echo " $line    $bstime         $betime">>logtmp
done 
echo "$roff : "
echo "$roff : ">>logtmp
for line in $(cat rlist);
  do
    rstime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "R*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
    retime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "R*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
    echo " $line    $rstime         $retime"
    echo " $line    $rstime         $retime">>logtmp
done 


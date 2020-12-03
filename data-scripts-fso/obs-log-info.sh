#!/bin/bash
#author: chen dong @fso
#purposes: summerize obs log info daily with regard to datatype
#
#changlog: 
#       20201203    Release 0.1.0     first working version 



cyear=`date  +%Y`
today=`date  +%Y%m%d`
today0=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
syssep="/"

if [ $# -ne 5 ];then
  echo "Usage: ./obs-log-info.sh destdir year monthday datatype(TIO or HA) mail(0-not send/1-send)"
  echo "Example: ./obs-log-info.sh  /lustre/data 2020 1203 TIO 1"
  echo "         ./obs-log-info.sh  /lustre/data 2020 1203 HA 0"
  exit 1
fi

progpre=$1
year=$2
monthday=$3
datatype=$4
mail=$5

homepre=/home/chd/data-info
obsdir=$homepre/$year
obslog=$homepre/$year/$datatype-obs-log-$year$monthday
targetdir=$progpre/$year/$year$monthday/$datatype
datadir=$targetdir/
device="lustre"

if [ ! -d "$obsdir" ]; then
  mkdir -m 777 -p $obsdir
fi
cent=" "
boff=" "
roff=" "
pver=0.1.0
if [ -d "$datadir" ]; then
    #DT=" HA"
    #cd $targetdir
    if [ "$datatype"=="HA" ]; then
        cent=`find $datadir -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*" -o -name "*FLAT*" -prune -false  -o  -type d -name  "CENT*" -print|awk -F "/" '{print $NF}'|uniq`
        boff=`find $datadir -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*" -o -name "*FLAT*" -prune -false  -o  -type d -name  "B*" -print|awk -F "/" '{print $NF}'|uniq`
        roff=`find $datadir -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*" -o -name "*FLAT*" -prune -false  -o  -type d -name  "R*" -print|awk -F "/" '{print $NF}'|uniq`
        find $targetdir/ -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "CENT*" -print>./clist-$datatype
        find $targetdir/ -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "B*" -print>./blist-$datatype
        find $targetdir/ -path "*redata*" -o -path "*dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "R*" -print>./rlist-$datatype
    fi
fi 
      
echo "$datatype Obs. Log of $year$monthday @fso:"> $obslog
echo "$cent $boff $roff"  >> $obslog
echo "$datatype Obs. Log of $year$monthday @fso:"
echo "$cent $boff $roff"  
if [ -d "$datadir" ]; then
    if [ "$datatype"=="HA" ]; then
        #echo "$cent : "
        echo "$cent : ">>$obslog
        for line in $(cat ./clist-$datatype);
        do
            cstime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "CENT*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
            cetime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "CENT*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
            #echo " $line    $cstime         $cetime"
            echo " $line    $cstime         $cetime">>$obslog
        done 
        #echo "$boff : "
        echo "$boff : ">>$obslog
        for line in $(cat ./blist-$datatype);
        do
            bstime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "B*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
            betime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "B*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
            #echo " $line    $bstime         $betime"
            echo " $line    $bstime         $betime">>$obslog
        done 
        #echo "$roff : "
        echo "$roff : ">>$obslog
        for line in $(cat ./rlist-$datatype);
        do
            rstime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "R*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
            retime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "R*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
            #echo " $line    $rstime         $retime"
            echo " $line    $rstime         $retime">>$obslog
        done 
    
        rm -f ./clist-$datatype
        rm -f ./blist-$datatype
        rm -f ./rlist-$datatype
    fi
fi    
#mail -s "Summary of $year$monthday $datatype @$device" nvst_obs@ynao.ac.cn < ./$datatype-mailtmp
if [ $mail -eq "1" ];then 
    mail -s "Summary of $year$monthday $datatype @$device" chd@ynao.ac.cn < $obslog
fi

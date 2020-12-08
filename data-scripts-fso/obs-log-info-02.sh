#!/bin/bash
#author: chen dong @fso
#purposes: summerize obs log info daily with regard to datatype
#
#changlog: 
#       20201203    Release 0.1.0     first working version 
#       20201206    Release 0.1.1     parse offband correctly
#       20201207    Release 0.1.7     add flat/dark info



cyear=`date  +%Y`

today0=`date  +%Y%m%d`
ctime0=`date  +%H:%M:%S`
today=`date  +%Y%m%d`
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
pver=0.1.2

today=`date  +%Y%m%d`
ctime=`date  +%H:%M:%S`
echo "$datatype Obs. Log of $year$monthday @fso:"> $obslog
echo "$today $ctime : $datatype Obs. Log of $year$monthday @fso:"
if [ -d "$datadir" ]; then
    cent=`find $datadir -path "*redata*"  -prune -false  -o  -type d -name  "CENT"  -not -path "*redata*" -print|awk -F "/" '{print $NF}'|uniq`
    boff=`find $datadir -path "*redata*"  -prune -false  -o  -type d -name  "B*"  -not -path "*redata*" -print|awk -F "/" '{print $NF}'|uniq`
    roff=`find $datadir -path "*redata*"  -prune -false  -o  -type d -name  "R*"  -not -path "*redata*" -print|awk -F "/" '{print $NF}'|uniq`
    flat=`find $datadir -path "*redata*"  -prune -false  -o  -type d -name  "FLAT*"  -not -path "*redata*" -print|awk -F "/" '{print $NF}'|uniq`
    dark=`find $datadir -path "*redata*"  -prune -false  -o  -type d -name  "dark*"  -not -path "*redata*" -print|awk -F "/" '{print $NF}'|uniq`
fi
echo $flat $dark $cent $boff $roff  >> $obslog
echo $flat $dark $cent $boff $roff

if [ $datatype == "TIO" ];then
    if [ -d "$datadir" ]; then 
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "FLAT*" -not -path "*redata*" -print>./flat-$datatype
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "dark*" -not -path "*redata*" -print>./dark-$datatype
        echo $flat $dark  >> $obslog
        echo $flat $dark 
        for bt in $(echo "$flat");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat ./flat-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then 
                fstime=`find $line/ -path "*redata*" -prune -false  -o  -type d -name  "FLAT*"  -not -path "*redata*" -print|xargs -I '{}' find {}/  -type f -name ''T*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                fetime=`find $line/ -path "*redata*" -prune -false  -o  -type d -name  "FLAT*"  -not -path "*redata*" -print|xargs -I '{}' find {}/  -type f -name ''T*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                echo " $line : $fstime         $fetime"
                echo " $line : $fstime         $fetime">>$obslog
                fi
            done
        done 
        for bt in $(echo "$dark");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat ./dark-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then 
                    dstime=`find $line/ -path "*redata" -prune -false  -o  -type d -name  "dark*"  -not -path "*redata*" -print|xargs -I '{}' find {}/  -type f -name ''T*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    detime=`find $line/ -path "*redata" -prune -false  -o  -type d -name  "dark*"  -not -path "*redata*" -print|xargs -I '{}' find {}/  -type f -name ''T*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $dstime         $detime"
                    echo " $line : $dstime         $detime">>$obslog
                fi
            done
        done  
    fi 
fi

if [ $datatype == "HA" ]; then
    if [ -d "$datadir" ]; then
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "CENT*" -not -path "*redata*" -print>./clist-$datatype
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "B*" -not -path "*redata*" -print>./blist-$datatype
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "R*" -not -path "*redata*" -print>./rlist-$datatype
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "FLAT*" -not -path "*redata*" -print>./flat-$datatype
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "dark*" -not -path "*redata*" -print>./dark-$datatype
        for bt in $(echo "$flat");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat ./flat-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then 
                    fstime=`find $line/ -path "*redata*" -prune -false  -o  -type d -name  "FLAT*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    fetime=`find $line/ -path "*redata*" -prune -false  -o  -type d -name  "FLAT*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $fstime         $fetime"
                    echo " $line : $fstime         $fetime">>$obslog
                fi
            done
        done 
        for bt in $(echo "$dark");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat ./dark-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then 
                    dstime=`find $line/ -path "*redata*" -prune -false  -o  -type d -name  "dark*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    detime=`find $line/ -path "*redata*" -prune -false  -o  -type d -name  "dark*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $dstime         $detime"
                    echo " $line : $dstime         $detime">>$obslog
                fi
            done
        done   
        for bt in $(echo "$cent");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat ./clist-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then 
                    cstime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "CENT" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    cetime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "CENT" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $cstime         $cetime"
                    echo " $line : $cstime         $cetime">>$obslog
                fi
            done
        done 
        for bt in $(echo "$boff");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat ./blist-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then
                    bstime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "B*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    betime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "B*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $bstime         $betime"
                    echo " $line : $bstime         $betime">>$obslog
                fi
            done
        done
        for bt in $(echo "$roff");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat ./rlist-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then
                    rstime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "R*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    retime=`find $line/ -path "*redata*" -o -path "*Dark*" -o -path "*DARK*" -o -path "*FLAT*"  -prune -false  -o  -type d -name  "R*" -print|xargs -I '{}' find {}/  -type f -name ''H*.fits'' -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $rstime         $retime"
                    echo " $line : $rstime         $retime">>$obslog
                fi
            done
        done
    fi
fi 
      

rm -f ./clist-$datatype
rm -f ./blist-$datatype
rm -f ./rlist-$datatype
  
if [ $mail -eq "1" ];then 
    mail -s "$datatype Obs. Log on $year$monthday @$device" chd@ynao.ac.cn < $obslog
    mail -s "$datatype Obs. Log on $year$monthday @$device" nvst_obs@ynao.ac.cn < $obslog
    mail -s "$datatype Obs. Log on $year$monthday @$device" xiangyy@ynao.ac.cn < $obslog
fi
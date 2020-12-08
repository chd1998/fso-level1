#!/bin/bash
#author: chen dong @fso
#purposes: summerize obs log info daily with regard to datatype
#
#changlog: 
#       20201203    Release 0.1.0       first working version 
#       20201206    Release 0.1.1       parse offband correctly
#       20201207    Release 0.1.2       add flat/dark info
#                   Release 0.1.3       tio info revised      



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
tmppre=/home/chd/tmp
device="lustre"

if [ ! -d "$obsdir" ]; then
  mkdir -m 777 -p $obsdir
fi
cent=" "
boff=" "
roff=" "
pver=0.1.3

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
#echo $flat $dark $cent $boff $roff  >> $obslog
#echo $flat $dark $cent $boff $roff

if [ $datatype == "TIO" ];then
    if [ -d "$datadir" ]; then 
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "FLAT*" -not -path "*redata*" -print>$tmppre/flat-$datatype
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "dark*" -not -path "*redata*" -print>$tmppre/dark-$datatype
        ls  -I "dark" -I "FLAT*" -I "*redata*" -I "*.log" $targetdir/|cut -d " " -f 1 >$tmppre/objlist-$datatype
        #echo $flat $dark   >> $obslog
        #echo $flat $dark 
        for bt in $(echo "$flat");
        do 
            #echo "$bt : "
            #echo "$bt : ">>$obslog
            for line in $(cat $tmppre/flat-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then 
                fstime=`find $line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                fetime=`find $line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                echo " $line : $fstime         $fetime"
                echo " $line : $fstime         $fetime">>$obslog
                fi
            done
        done 
        for bt in $(echo "$dark");
        do 
            #echo "$bt : "
            #echo "$bt : ">>$obslog
            for line in $(cat $tmppre/dark-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then 
                    dstime=`find $line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    detime=`find $line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $dstime         $detime"
                    echo " $line : $dstime         $detime">>$obslog
                fi
            done
        done
        for line in $(cat $tmppre/objlist-$datatype);
        do
            ostime=`find $targetdir/$line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
            oetime=`find $targetdir/$line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
            echo " $targetdir/$line : $ostime         $oetime"
            echo " $targetdir/$line : $ostime         $oetime">>$obslog
        done  
    fi 
fi

if [ $datatype == "HA" ]; then
    if [ -d "$datadir" ]; then
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "CENT*" -not -path "*redata*" -print>$tmppre/clist-$datatype
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "B*" -not -path "*redata*" -print>$tmppre/blist-$datatype
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "R*" -not -path "*redata*" -print>$tmppre/rlist-$datatype
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "FLAT*" -not -path "*redata*" -print>$tmppre/flat-$datatype
        find $targetdir/ -path "*redata*" -prune -false  -o  -type d -name  "dark*" -not -path "*redata*" -print>$tmppre/dark-$datatype
        for bt in $(echo "$flat");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat $tmppre/flat-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then 
                    fstime=`find $line/ -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    fetime=`find $line/ -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $fstime         $fetime"
                    echo " $line : $fstime         $fetime">>$obslog
                fi
            done
        done 
        for bt in $(echo "$dark");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat $tmppre/dark-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then 
                    dstime=`find $line/ -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    detime=`find $line/ -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $dstime         $detime"
                    echo " $line : $dstime         $detime">>$obslog
                fi
            done
        done   
        for bt in $(echo "$cent");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat $tmppre/clist-$datatype);
            do
                result=$(echo $line|grep "${bt}")
                if [[ "$result" != "" ]]
                then 
                    cstime=`find $line/ -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    cetime=`find $line/ -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $cstime         $cetime"
                    echo " $line : $cstime         $cetime">>$obslog
                fi
            done
        done 
        for bt in $(echo "$boff");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat $tmppre/blist-$datatype);
            do
                result=$(echo $line|grep "${bt}"|grep -v FLAT)
                if [[ "$result" != "" ]]
                then
                    bstime=`find $line/ -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    betime=`find $line/ -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $bstime         $betime"
                    echo " $line : $bstime         $betime">>$obslog
                fi
            done
        done
        for bt in $(echo "$roff");
        do 
            echo "$bt : "
            echo "$bt : ">>$obslog
            for line in $(cat $tmppre/rlist-$datatype);
            do
                result=$(echo $line|grep "${bt}"|grep -v FLAT)
                if [[ "$result" != "" ]]
                then
                    rstime=`find $line/ -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1|head -n +1`
                    retime=`find $line/ -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 -r|head -n +1`
                    echo " $line : $rstime         $retime"
                    echo " $line : $rstime         $retime">>$obslog
                fi
            done
        done
    fi
fi 
      

rm -f $tmppre/clist-$datatype
rm -f $tmppre/blist-$datatype
rm -f $tmppre/rlist-$datatype
rm -f $tmppre/dark-$datatype
rm -f $tmppre/flat-$datatype
  
if [ $mail -eq "1" ];then 
    mail -s "$datatype Obs. Log on $year$monthday @$device" chd@ynao.ac.cn < $obslog
    mail -s "$datatype Obs. Log on $year$monthday @$device" nvst_obs@ynao.ac.cn < $obslog
    mail -s "$datatype Obs. Log on $year$monthday @$device" xiangyy@ynao.ac.cn < $obslog
fi
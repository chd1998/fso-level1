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

checkmonth=${monthday:0:2}
checkday=${monthday:2:2}

homepre=/home/chd/data-info
obsdir=$homepre/$year
obslog=$homepre/$year/$datatype-obs-log-$year$monthday
targetdir=$progpre/$year/$year$monthday/$datatype
datadir=$targetdir/
tmppre=/home/chd/tmp
obstmp=$tmppre/$datatype-$year$monthday.tmp
stimetmp=$tmppre/start-$datatype-$year$monthday-time.tmp
etimetmp=$tmppre/end-$datatype-$year$monthday-time.tmp
stime=$tmppre/start-$datatype-$year$monthday-time
etime=$tmppre/end-$datatype-$year$monthday-time
obstime=$tmppre/obs-$datatype-$year$monthday-time
device="lustre"

if [ ! -d "$obsdir" ]; then
  mkdir -m 777 -p $obsdir
fi
cent=" "
boff=" "
roff=" "
pver=0.1.4

tobstime=0.0

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
                    find $line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 > $obstmp
                    fstime=`cat $obstmp|head -n +1`
                    fetime=`cat $obstmp|sort -r|grep $checkmonth-$checkday|head -n +1`
                    s1=`date -d "$fstime" +%s`
                    e1=`date -d "$fetime" +%s`
                    i1=`echo "$s1 $e1"|awk '{print(($2-$1)/3600)}'`
                    echo $fstime> $stimetmp
                    echo $fetime> $etimetmp
                    echo " $line : $fstime         $fetime          $i1"
                    echo " $line : $fstime         $fetime          $i1">>$obslog
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
                    find $line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 > $obstmp
                    dstime=`cat $obstmp|head -n +1`
                    detime=`cat $obstmp|sort -r | grep $checkmonth-$checkday|head -n +1`
                    s2=`date -d "$dstime" +%s`
                    e2=`date -d "$detime" +%s`
                    i2=`echo "$s2 $e2"|awk '{print(($2-$1)/3600)}'`
                    echo $dstime>> $stimetmp
                    echo $detime>> $etimetmp
                    echo " $line : $dstime         $detime          $i2"
                    echo " $line : $dstime         $detime          $i2">>$obslog
                fi
            done
        done
        for line in $(cat $tmppre/objlist-$datatype);
        do
            find $targetdir/$line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 > $obstmp
            ostime=`cat $obstmp|head -n +1`
            oetime=`cat $obstmp|sort -r | grep $checkmonth-$checkday|head -n +1`
            s3=`date -d "$ostime" +%s`
            e3=`date -d "$oetime" +%s`
            i3=`echo "$s3 $e3"|awk '{print(($2-$1)/3600)}'`
            echo $ostime>> $stimetmp
            echo $oetime>> $etimetmp
            echo " $targetdir/$line : $ostime         $oetime           $i3"
            echo " $targetdir/$line : $ostime         $oetime           $i3">>$obslog
        done  
    fi 
    tobstime=`echo $i1 $i2 $i3|awk '{print($1+$2+$3)}'`
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
                    find $line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 > $obstmp
                    fstime=`cat $obstmp|head -n +1`
                    fetime=`cat $obstmp|sort -r | grep $checkmonth-$checkday|head -n +1`
                    s1=`date -d "$fstime" +%s`
                    e1=`date -d "$fetime" +%s`
                    i1=`echo "$s1 $e1"|awk '{print(($2-$1)/3600)}'`
                    echo $fstime>> $stimetmp
                    echo $fetime>> $etimetmp
                    echo " $line : $fstime         $fetime          $i1"
                    echo " $line : $fstime         $fetime          $i1">>$obslog
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
                    find $line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 > $obstmp
                    dstime=`cat $obstmp|head -n +1`
                    detime=`cat $obstmp|sort -r | grep $checkmonth-$checkday|head -n +1`
                    s2=`date -d "$dstime" +%s`
                    e2=`date -d "$detime" +%s`
                    i2=`echo "$s2 $e2"|awk '{print(($2-$1)/3600)}'`
                    echo $dstime>> $stimetmp
                    echo $detime>> $etimetmp
                    echo " $line : $dstime         $detime          $i2"
                    echo " $line : $dstime         $detime          $i2">>$obslog
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
                    find $line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 > $obstmp
                    cstime=`cat $obstmp|head -n +1`
                    cetime=`cat $obstmp|sort -r | grep $checkmonth-$checkday|head -n +1`
                    s3=`date -d "$cstime" +%s`
                    e3=`date -d "$cetime" +%s`
                    i3=`echo "$s3 $e3"|awk '{print(($2-$1)/3600)}'`
                    echo $cstime>> $stimetmp
                    echo $cetime>> $etimetmp
                    echo $cstime>> $stimetmp
                    echo $cetime>> $etimetmp
                    echo " $line : $cstime         $cetime          $i3"
                    echo " $line : $cstime         $cetime          $i3">>$obslog
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
                    find $line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 > $obstmp
                    bstime=`cat $obstmp|head -n +1`
                    betime=`cat $obstmp|sort -r | grep $checkmonth-$checkday|head -n +1`
                    s4=`date -d "$bstime" +%s`
                    e4=`date -d "$betime" +%s`
                    i4=`echo "$s2 $e2"|awk '{print(($2-$1)/3600)}'`
                    echo $bstime>> $stimetmp
                    echo $betime>> $etimetmp
                    echo " $line : $bstime         $betime          $i4"
                    echo " $line : $bstime         $betime          $i4">>$obslog
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
                    find $line/   -type f -name *.fits -not -path "*redata*" -print|xargs stat 2>/dev/null|grep Modify|awk '{print($2" "$3)}'|sort --field-separator=" " --key=1 > $obstmp
                    rstime=`cat $obstmp|head -n +1`
                    retime=`cat $obstmp|sort -r | grep $checkmonth-$checkday|head -n +1`
                    s5=`date -d "$rstime" +%s`
                    e5=`date -d "$retime" +%s`
                    i5=`echo "$s5 $e5"|awk '{print(($2-$1)/3600)}'`
                    echo $rstime>> $stimetmp
                    echo $retime>> $etimetmp
                    echo " $line : $rstime         $retime          $i5"
                    echo " $line : $rstime         $retime          $i5">>$obslog
                fi
            done
        done
    fi
    tobstime=`echo $i1 $i2 $i3 $i4 $i5|awk '{print($1+$2+$3+$4+$5)}'`
fi 
cat $stimetmp|sort|head -n +1 > $stime
cat $etimetmp|sort -r|grep $checkmonth-$checkday|head -n +1 > $etime
echo $tobstime > $obstime

rm -f $tmppre/clist-$datatype
rm -f $tmppre/blist-$datatype
rm -f $tmppre/rlist-$datatype
rm -f $tmppre/dark-$datatype
rm -f $tmppre/flat-$datatype
rm -f $tmppre/objlist-$datatype
rm -f $obstmp
  
if [ $mail -eq "1" ];then 
    mail -s "$datatype Obs. Log on $year$monthday @$device" chd@ynao.ac.cn < $obslog
    mail -s "$datatype Obs. Log on $year$monthday @$device" nvst_obs@ynao.ac.cn < $obslog
    mail -s "$datatype Obs. Log on $year$monthday @$device" xiangyy@ynao.ac.cn < $obslog
fi
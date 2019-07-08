#!/bin/bash
#author: chen dong @fso
#purposes: manually syncing TIO/HA data in specified year(eg., 2019...) from remoteip to local lustre storage via lftp
#Usage: ./fso-copy.sh srcip dest year(4 digits)  monthday(4 digits) datatype(TIO/HA)
#Example: ./fso-copy.sh ftp://192.168.111.120 /lustre/data 2019 0427 TIO
#changlog: 
#        20190420       Release 0.1 first prototype release 0.1
#        20190421       Release 0.2 fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
#        20190423       Release 0.3 fix errors
#        20190426       Release 0.4 fix errors
#        20190428       Release 0.5 add monthday to the src dir
#                       Release 0.6 datatype is an option now
#        20190603       Release 0.7 using lftp instead of wget
#        20190604       Release 0.8 add progress bar to lftp
#        20190608       Release 0.9 fixed error in directory
#                       Release 1.0 improve display info
#        20190702       Release 1.1 revise some logical relations
#        20190704       Release 1.2 using lftp & add input args
#        20190705       Release 1.3 logics revised
#
#waiting pid taskname prompt
waiting() {
        local pid="$1"
        taskname="$2"
        procing "$3" &
        local tmppid="$!"
        wait $pid
        tput rc
        tput ed
	ctime=`date --date='0 days ago' +%H:%M:%S`
	today=`date --date='0 days ago' +%Y%m%d`
        echo "$today $ctime: $2 Task Has Done!"
        dt1=`echo $ctime|tr '-' ':' | awk -F: '{ total=0; m=1; } { for (i=0; i < NF; i++) {total += $(NF-i)*m; m *= i >= 2 ? 24 : 60 }} {print total}'`
#        echo "                   Finishing..."
        kill -6 $tmppid >/dev/null 1>&2
        echo "$dt1" > dtmp.dat
#        return $dt1
}

procing() {
        trap 'exit 0;' 6
        tput ed
        while [ 1 ]
        do
            for j in '-' '\\' '|' '/'
            do
                tput sc
                ptoday=`date --date='0 days ago' +%Y%m%d`
                pctime=`date --date='0 days ago' +%H:%M:%S`
                echo -ne  "$ptoday $pctime: $1...   $j"
                sleep 0.2
                tput rc
          done
        done
}

ls -lR . | grep "^-" | wc -l > tmpfn.dat &
waiting "$!" "File Number Sumerizing" "Sumerizing File Number"
d1=$(cat dtmp.dat)

du -sm . |awk '{print $1}' > tmpfs.dat &
waiting "$!" "File Size Summerizing" "Sumerizing File Size"
d2=$(cat dtmp.dat)
dd=$(($d2-$d1))
echo " "
echo "$d1  --- $d2"
echo "$dd"

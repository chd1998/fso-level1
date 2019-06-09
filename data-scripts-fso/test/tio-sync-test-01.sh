#!/bin/bash

waiting() {
        local pid="$1"
#        msg "$2... ..." '' -n
#	echo "$2..."	
        procing &
        local tmppid="$!"
        wait $pid
        #恢复光标到最后保存的位置
        tput rc
 	tput ed        
        echo "done!"                          
#        msg "done" $boldblue
        kill -6 $tmppid >/dev/null 1>&2
}

    #   输出进度条, 小棍型
procing() {
        trap 'exit 0;' 6
        tput ed
        while [ 1 ]
        do
            for j in '-' '\\' '|' '/'
            do
                #保存当前光标所在位置
                tput sc                         
                echo -ne  "working...   $j"
                sleep 0.5
                #恢复光标到最后保存的位置
                tput rc                         
           done
        done 
}

date
lftp -u tio,ynao246135 -e "mirror --ignore-time --continue --exclude /\$RECYCLE.BIN/$  --parallel=33  / .; quit" ftp://192.168.111.120:21 > /dev/null 2>&1 &
waiting "$!" "Syncing..."
#waiting "$!" "sleeping..."
#wait  ##等待所有子后台进程结束
date

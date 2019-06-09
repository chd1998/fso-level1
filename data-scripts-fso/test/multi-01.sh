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
        echo "done!"                          
#        msg "done" $boldblue
        kill -6 $tmppid >/dev/null 2>&1
}

    #   输出进度条, 小棍型
procing() {
        trap 'exit 0;' 6
        while [ 1 ]
        do
            for j in '-' '\\' '|' '/'
            do
                #保存当前光标所在位置
                tput sc                         
                echo -ne  "working...   $j"
                sleep 0.1
                #恢复光标到最后保存的位置
                tput rc                         
          done
        done
}

date
for i in `seq 1 5`
do
{
    echo "$i: sleep 5"
    sleep 5
} 
done &
waiting "$!" "waiting..." ##等待所有子后台进程结束
date

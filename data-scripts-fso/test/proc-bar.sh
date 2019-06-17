#!/bin/bash
waiting() {
        local pid="$1"
        msg "$2... ..." '' -n
        procing &
        local tmppid="$!"
        wait $pid
        #恢复光标到最后保存的位置
        tput rc                                 
        msg "done" $boldblue
        kill -6 $tmppid >/dev/null 1>&2
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
                echo -ne  "$j"
                sleep 1
                #恢复光标到最后保存的位置
                tput rc                         
          done
        done 
}
#   解压数据
zip_data() {
        local proc="$1";
        begin "$proc";

        zip 1Gb.file . &
        waiting "$!" "正在压缩"

        ret="$?"
        judge "$proc"

}

   
zip_data

    #!/bin/bash 
    LOCKFILE=/tmp/$(basename $0)_lockfile 
     
    if [ -f $LOCKFILE  ];then 
            MYPID=$(cat $LOCKFILE) 
            ps -p $MYPID | grep $MYPID &>/dev/null 
            [ $? -eq 0 ] && echo "The script backup.sh is running" && exit 1 
    else 
            echo $$ > $LOCKFILE 
    fi 
    echo "The script is running!" 
    read 
    echo "The script is stop!" 
    rm -rf $LOCKFILE 

    #!/bin/bash 
   #echo $(basename $0) 
   LOCKFILE=/tmp/$(basename $0)_lockfile 
   echo $LOCKFILE  
    if [ -f $LOCKFILE  ];then 
            MYPID=$(cat $LOCKFILE) 
            echo $MYPID
            ps -p $MYPID | grep $MYPID &>/dev/null 
            echo $?
            if [ $? -eq 0 ];then
		 echo "The script $(basename $0) is running" 
		 exit 1 
            fi
    else 
            echo $$ > $LOCKFILE 
    fi 
    echo "The script is running!" 
    read 
    echo "The script is stop!" 
    rm -rf $LOCKFILE 

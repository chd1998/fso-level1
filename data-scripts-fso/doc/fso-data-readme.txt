1. fso-sync-lftp-v08.sh

purposes: periodically syncing today's data from remoteip to local lustre storage via lftp, run in crontab every 1 min.  from 08:00-19:59
usage:  /home/chd/fso-sync-lftp-v08.sh serverip port destsuffix user passwd datatype processesnumber
example: /home/chd/fso-sync-lftp-v08.sh  192.168.111.120 21 /lustre/data tio ynao246135 TIO 40 >> /home/chd/log/fso-sync-tio.log
changlog:
       20190603    Release 0.1     first version for tio-sync.sh
       20190625    Release 0.2     revised lftp performance & multi-thread
       20190703    Release 0.3     fix some errors
       20190705    Release 0.4     timing logic revised
       20190715    Release 0.5     reduce time of changing permission
       20190716    Release 0.6     add parallel permission changing
                   Release 0.7     input parallel lftp thread number
       20190718    Release 0.8     add remote data info
       
2. fso-copy-lftp-v14.sh
purposes: manually syncing TIO/HA data in specified yearmonthday(eg., 20190705) from remoteip to local lustre storage via lftp
Usage: ./fso-copy-lftp-v14.sh srcip dest year(4 digits)  monthday(4 digits) datatype(TIO/HA)
Example: ./fso-copy-lftp-v14.sh ftp://192.168.111.120 /lustre/data 2019 0427 TIO
changlog:
        20190420       Release 0.1 first prototype release 0.1
        20190421       Release 0.2 fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
        20190423       Release 0.3 fix errors
        20190426       Release 0.4 fix errors
        20190428       Release 0.5 add monthday to the src dir
                       Release 0.6 datatype is an option now
        20190603       Release 0.7 using lftp instead of wget
        20190604       Release 0.8 add progress bar to lftp
        20190608       Release 0.9 fixed error in directory
                       Release 1.0 improve display info
        20190702       Release 1.1 revise some logical relations
        20190704       Release 1.2 using lftp & add input args
        20190705       Release 1.3 logics revised
                       Release 1.4 revise timing logics
                       
3. fso-count-lftp.sh
purposes: periodically getting today's data info from remote site via lftp,run in crontab every 30 min.  from 08:00-19:59
usage:  fso-count-lftp.sh  servreip port user passwd datatype
example: fso-count-lftp.sh  192.168.111.120 21  tio ynao246135 TIO >> /home/chd/log/fso-remote-info-tio.log
changlog:
        20190718    Release 0.1     first working version
                                                            
4. fso-data-check-copy-cron.sh
purposes: check the data & copy the wrong file(s) again, call fso-data-check-cron.sh & fso-copy-wget-error-cron-v02.sh
Usage: ./fso-data-check-copy-cron.sh ip port  destdir user password datatype(TIO or HA) threadnumber
Example: ./fso-data-check-copy-cron.sh  192.168.111.120 21 /lustre/data tio ynao246135 TIO fits 11062080
Example: ./fso-data-check-copy-cron.sh  192.168.111.122 21 /lustre/data ha ynao246135 HA fits 2111040
changlog:
       20190725   Release 0.1     first working version.sh

4.1 fso-data-check-cron.sh
check the size of dest dir after syncing, and export total error list in file
usage: ./fso-data-check-xx.sh /youdirhere/ datatype fileformat standardsize(in bytes)
example: ./fso-data-check-cron.sh /lustre/data/2019/20190721/TIO TIO fits 11062080
example: ./fso-data-check-cron.sh /lustre/data/2019/20190721/HA HA fits 2111040
change log:
           Release 20190721-0931: First working prototype
           
4.2 fso-copy-wget-error-cron-v02.sh
Purposes: Copy file of wrong size TIO/HA data in errorlist from remote host to dest
Usage: ./fso-copy-wget-error-cron-v02.sh srcip port user passwd error-file-list
Example: ./fso-copy-wget-error-cron-v02.sh ftp://192.168.111.120 21 tio ynao246135  error.list
Changlog:
        20190723       Release 0.1   first prototype release 0.1
        20190725       Release 0.2   revised logics


5. fso-copy-wget-v12-single.sh  fso-copy-wget-v14-multi.sh
purposes: manually syncing TIO/HA data in specified date(eg., 2019 0427) from remoteip to local lustre storage via lftp
Usage: ./fso-copy-wget-vxx-xx.sh srcip dest year(4 digits)  monthday(4 digits) datatype(TIO/HA)
Example: ./fso-copy-wget-vxx-xx.sh ftp://192.168.111.120 /lustre/data 2019 0427 TIO
changlog:
        20190420       Release 0.1 first prototype release 0.1
        20190421       Release 0.2 fix bugs,using pid as lock to prevent script from multiple starting, release 0.2
        20190423       Release 0.3 fix errors
        20190426       Release 0.4 fix errors
        20190428       Release 0.5 add monthday to the src dir
                       Release 0.6 datatype is an option now
        20190603       Release 0.7 using lftp instead of wget
        20190604       Release 0.8 add progress bar to lftp
        20190608       Release 0.9 fixed error in directory
                       Release 1.0 improve display info
        20190702       Release 1.1 revise some logical relations
        20190703       Release 1.2 using wget in case of lftp failure
                       Release 1.3 using multiple wget
        20190719       Release 1.4 revised multi wget performance


6. luster2hd.sh
                                                                                                                                                               
Purposes: mount HD to /data directory, copy HD to /lustre/data and safely unmount HD
Directory: /home/chd
Usage: ./lustre2hd.sh srcdir destdir year(4digits) monthday(4digits) datatype(TIO/HA)
Example: ./lustre2hd.sh /lustre/data  /data 2019 0420 TIO
Changelog:
         20190420      Release 0.1     first working script
         20190421      Release 0.2     fixed minor errors, and using cp instead of rsync
         20190426      Release 0.3     fixed minor display problems
                       Release 0.4     sum the file num and size both in src and dest
         20190625      Release 0.5     calculate speed of copying                     



 
7. hd2lustre-all-v15.sh hd2lustre-single-v16.sh
Purposes: mount HD to /data directory, copy HD to /lustre/data and safely unmount HD
Usage: ./hd2lustre-single-vxx.sh srcdir destdir year(4 digits) monthday(4 digits) datatype(TIO or HA)
       ./hd2lustre-all-vxx.sh srcdir destdir year(4 digits) datatype(TIO or HA)
Example: ./hd2lustre-single-vxx.sh  /data  /lustre/data 2019 0707 TIO
         ./hd2lustre-all-v15.sh /data  /lustre/data 2019 TIO
Changelog:
         20190420 Release 0.1, first working script
         20190421 Release 0.2, fixed minor errors, and using cp instead of rsync
         20190423 Release 0.3, fixed error in reading parameters inputed
         20190423 Release 0.4, judge the srcdir is empty or not
         20190424 Release 0.5, fixed some error in copying
         20190424 Release 0.6, add datatype as input to improve speed for chmoding
         20190425 Release 0.7, add more info for chmod
                              Release 0.8, sum of the data copied in MB
                  Release 0.9, sum of file numbers both in src and dest
         20190625 Release 1.0, add speed info
         20190708 Release 1.1, add checking dest dir in year specified
                               add datatype to destdir if missing in src
                  Release 1.2, copy data of single day only
         20190710 Release 1.4, copy process indicator added   
         20190711 Release 1.5, using tar & pv to copy data with all dirs  
                  Release 1.6, revised for copying only single dir	
                                               
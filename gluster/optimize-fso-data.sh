#!/bin/bash
gluster volume set fso-data auth.allow 192.168.*
gluster volume set fso-data network.ping-timeout 10
gluster volume set fso-data server.event-threads 4
gluster volume set fso-data server.outstanding-rpc-limit  128
gluster volume set fso-data cluster.read-hash-mode 2
gluster volume set fso-data cluster.lookup-optimize on
gluster volume set fso-data cluster.heal-timeout 300
gluster volume set fso-data lookup-unhashed off
gluster volume set fso-data performance.read-ahead on
gluster volume set fso-data performance.cache-size 512MB
gluster volume set fso-data performance.write-behind-window-size 512MB
gluster volume set fso-data performance.io-thread-count 32
gluster volume set fso-data performance.client-io-threads on
gluster volume set fso-data nfs.disable on
gluster volume set fso-data storage.linux-aio on
cpufreq-set -g performance
#echo "deadline" > /sys/block/sda/queue/scheduler

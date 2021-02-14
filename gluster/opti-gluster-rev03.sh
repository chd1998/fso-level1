#!/bin/bash
# $1 is the volume name of gluster cluster

if [ $# -ne 1 ];then
  echo "Usage: .$(basename $0) volume_name"
  echo "Example: $(basename $0)  df3600"
  exit 1
fi

volname=$1

gluster volume set $volname network.ping-timeout 10
gluster volume set $volname server.event-threads 4
gluster volume set $volname server.outstanding-rpc-limit  128
gluster volume set $volname client.event-threads 8
gluster volume set $volname cluster.read-hash-mode 2
gluster volume set $volname cluster.lookup-optimize on
gluster volume set $volname cluster.heal-timeout 300
gluster volume set $volname group metadata-cache
gluster volume set $volname lookup-unhashed off
gluster volume set $volname performance.read-ahead on
gluster volume set $volname performance.cache-size 512MB
gluster volume set $volname performance.write-behind-window-size 512MB
gluster volume set $volname performance.io-thread-count 32
gluster volume set $volname performance.client-io-threads on
gluster volume set $volname performance.parallel-readdir on
gluster volume set $volname performance.md-cache-timeout 0
gluster volume set $volname nfs.disable on
gluster volume set $volname storage.linux-aio on
gluster volume set $volname stat-prefetch on
gluster volume set $volname storage.health-check-interval 2592000
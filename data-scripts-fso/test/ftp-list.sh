#!/bin/bash
ftp -v -n 192.168.111.120<<EOF
user tio ynao246135
cd /20190704/TIO
!du -sm

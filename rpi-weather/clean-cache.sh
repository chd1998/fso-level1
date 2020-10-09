#!/bin/sh
lsof -n /fso-cache |grep deleted|awk '{print $2}'|xargs kill -9
rm -f /fso-cache/*
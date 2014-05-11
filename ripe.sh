#!/bin/bash
if [ ! "$#" -eq 1 ];then
	echo "$0 ripelist"
else
	echoerr() { echo -e "$@" 1>&2; }
	db=7
	ripelist=$1
	ripe2redis () {
		while read data;do
			local startip endip netname country line=$data
			IFS="|" read -r startip endip netname country <<< "$line"
			printf '*8\r\n$4\r\nZADD\r\n$%d\r\n%s\r\n$1\r\n1\r\n$%d\r\n%s\r\n$1\r\n2\r\n$%d\r\n%s\r\n$1\r\n3\r\n$%d\r\n%s\r\n' "${#startip}" "${startip}" "${#endip}" "${endip}" "${#netname}" "${netname}" "${#country}" "${country%%|*}"
			done
	}

	export -f ripe2redis
	echoerr "\nflush redis db: $db"
	redis-cli -n $db flushdb
	echoerr "\nZADD ripe ranges in redis db: $db"
	time cat "${ripelist}" | ripe2redis | redis-cli -n 7 --pipe
fi

#!/bin/bash
if [ ! "$#" -eq 1 ];then
	echo "$0 iplist"
else
	echoerr() { echo -e "$@" 1>&2; }
	db=6
	iplist=$1
	ip2redis () {
		while read data;do
			local ip=$data
			printf '*3\r\n$3\r\nSET\r\n$%d\r\n%s\r\n$%d\r\n%s\r\n' "${#ip}" "${ip}" "${#ip}" "${ip}"
		done
	}

	export -f ip2redis
	echoerr "\nflush redis db: $db"
	redis-cli -n $db flushdb
	echoerr "\nSET ips in redis db: $db"
	time cat "${iplist}" | ip2redis | redis-cli -n $db --pipe
fi

#!/bin/bash
if [ ! "$#" -eq 1 ];then
	echo "$0 ripelist"
else
	echoerr() { echo -e "$@" 1>&2; }
	db=7
	ripelist=$1
	echoerr "splitting input file into temp/"
	mkdir -p temp
	split -l 10000 $1 temp/ZZZ
	nrfiles=$(ls temp/ |wc -l)
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
	echoerr "we'll be parsing $nrfiles times 10000 rows"
	counter=1
	time for file in $(ls temp/); do cat "temp/${file}" | ripe2redis | redis-cli -n 7 --pipe && echo $counter && let counter=counter+1; done
	rm "temp/ZZZ*"
fi

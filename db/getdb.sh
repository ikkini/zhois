#!/bin/bash
datum=$(date +%F)
#wget -o /dev/null --background ftp://ftp.ripe.net/ripe/dbase/ripe.db.gz -O ripe.${datum}.gz
#gunzip ripe.${datum}.gz
# mv ripe.${datum} ripe.${datum}.db
# TODO below ugliness thanks to the mess that is whois. Below still has problems.
egrep "^inetnum:|^netname:" ripe.2014-04-30 |tr '\n' ' ' | tr -s ' ' |sed 's/ inetnum: /\|/g' | tr '|' '\n' |sed 's/ netname: /\|/g;s/ - /\|/g' |grep "^[[:digit:]]" |sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n > ripe.db

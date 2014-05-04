#!/bin/bash
datum=$(date +%F)
#rm ripe*db
#rm ripe*src
#wget ftp://ftp.ripe.net/ripe/dbase/ripe.db.gz -O ripe.gz
#gunzip ripe.gz
#mv ripe ripe.src
# TODO below ugliness thanks to the mess that is whois. Below still has problems.
#egrep "^inetnum:|^netname:|^country:" ripe.src | tr '\n' ' ' | tr -s ' ' |sed 's/ inetnum: /\|/g' | tr '|' '\n' |sed 's/ netname: /\|/g;s/ country: /\|/g;s/ - /\|/g'|grep "^[[:digit:]]" |sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n > ripe.txt.src
rm ripe.db

sqlite3 ripe.db <<EOF
create table inetnum (ipmin integer, ipmax integer, netname text, country text);
.separator "|"
.import ripe.txt.src inetnum
EOF

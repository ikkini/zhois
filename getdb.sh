#!/bin/bash
download () {
datum=$(date +%F)
echo "remove old db's"
rm ripe*db
rm ripe*src
echo "get ripe db"
wget ftp://ftp.ripe.net/ripe/dbase/ripe.db.gz -O ripe.gz
gunzip ripe.gz
mv ripe ripe.src
}
# TODO below ugliness thanks to the mess that is whois output.
# PS: This must be the smallest execuse (for a) RFC ever: http://tools.ietf.org/html/rfc3912
parse () {
db=$1
echo "create $(dirname "${1}")/ripe.txt.src inetnum|netname|country file from $db"
egrep "^inetnum:|^netname:|^country:" $1 | tr '\n' ' ' | tr -s ' ' |sed 's/ inetnum: /\|/g' | tr '|' '\n' |sed 's/ netname: /\|/g;s/ country: /\|/g;s/ - /\|/g'|grep "^[[:digit:]]" > $(dirname "${1}")/ripe.txt.src
}
# remove superflous RIPE ranges
fix () {
echo "fix the ripe ranges dataset, removing superfluous data"
echo "remove 0.0.0.0/0 range"
gsed -i '/0.0.0.0|255.255.255.255|IANA-BLK|EU.*/d' $(dirname "${1}")/ripe.txt.src
cut -d '|' -f 1,2,3,4 $(dirname "${1}")/ripe.txt.src > $(dirname "${1}")/ripe.db
}
cleanup () {
	rm ripe.src
	rm ripe.txt.src
}
parse $1
fix $1


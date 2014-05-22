#!/bin/bash
if [ "$#" -ne 1 ]; then
	echo "Define target dir/file for ripe src"
	exit 1
fi

download () {
	src=$1
	echo "get ripe db"
	wget ftp://ftp.ripe.net/ripe/dbase/ripe.db.gz -O $(dirname "${src}")/ripe.gz
	zcat $(dirname "${src}")/ripe.gz > ${src}
}
# TODO below ugliness thanks to the mess that is whois output.
# PS: This must be the smallest execuse (for a) RFC ever: http://tools.ietf.org/html/rfc3912
parse () {
	src=$1
	if [ -f "${src}" ]
	then
	echo "create $(dirname "${src}")/ripe.formatted.src inetnum|netname|country file from $src"
	egrep "^inetnum:|^country:|^netname:|^$" "${src}"  |sed 's/inetnum:/%inetnum:/g' |tr '\n' ' ' |tr -s ' ' | tr '%' '\n' | sed 's/^inetnum://g;s/ - /|/g;s/ netname: /|netname:/g;s/ country: /|country:/g' | grep "^ [[:digit:]]" | cut -f 1,2,3,4 -d '|'> $(dirname "${1}")/ripe.formatted.src
else
	echo "source file does not exist"
	exit 1
fi
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
download $1
parse $1


#!/bin/bash
if [ "$#" -ne 1 ]; then
	echo "Define target file for ripe src. Will be put under src/"
	exit 1
fi

download () {
	src=$1
	echo "get ripe db"
	# make sure src directory exists
	# get ripe daily database
	# stage in src
	if [ -d src ]; then
		continue
	else
		mkdir src
	fi
	wget ftp://ftp.ripe.net/ripe/dbase/ripe.db.gz -O src/ripe.gz
	zcat src/ripe.gz > src/${src}
}
# Below ugliness thanks to the mess that is whois output.
# PS: This must be the smallest execuse (for a) RFC ever: http://tools.ietf.org/html/rfc3912
parse () {
	src=$1
	if [ -f "${src}" ]
	then
	echo "create src/ripe.formatted.src inetnum|netname|country file from $src"
	# grepping for inetnum/country/netname/empty lines
	# TODO still have to find out whether matching empty lines actually helps keep the cruft down
	# breaking the line before inetnum, removing spaces
	# removing all lines not beginning with a digit (cruft)
	# removing all fields after the forth (a lot of superfluous country/netname entries)
	egrep "^inetnum:|^country:|^netname:|^$" "src/${src}"  |sed 's/inetnum:/%inetnum:/g' |\
		tr '\n' ' ' |tr -s ' ' | tr '%' '\n' |\
		sed 's/^inetnum://g;s/ - /|/g;s/ netname: /|netname:/g;s/ country: /|country:/g' |\
	       	grep "^ [[:digit:]]" | cut -f 1,2,3,4 -d '|'> src/ripe.formatted.src
else
	echo "source file does not exist"
	exit 1
fi
}

download $1
parse $1


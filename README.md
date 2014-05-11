# zhois
## A tool created to efficiently whois all hosts found with zmap


## some memory profiling

	sudo pip-3.2 install psutil
	sudo pip-3.2 install memory_profiler

set up memory profiling '''from memory_profiler import profile'''

# Move to using redis

Two scripts ip.sh and ripe.sh dump the contents of an iplist and a pre-formatted list of RIPE ranges (for now) into two redid db's (6 and 7).

The zhois script walks through potential network addresses (from largest to smallest network address) looking for the first match in the ripe dataset.
For now it just prints the match.

One thing to still solve: there is a mismatch between de number of lines in the ripe source and the number of entries in de ripe redis db. I've already checked, it is not overlapping network addresses (although those do exist).

This does not happen with the first "n" thousand records, so I'll continue to debug. 

PS: where there is a collision in network addresses, ZADD should add the broadcast address + network name + country as a new field in the sorted set, so that should not matter.


$ ./ripe.sh db/ripe.db
splitting input file into temp/

flush redis db: 7
OK

ZADD ripe ranges in redis db: 7
we'll be parsing      387 times 10000 rows
All data transferred. Waiting for the last reply...
Last reply received from server.
errors: 0, replies: 10000
1

[...]

real30m7.884s
user14m44.514s
sys17m30.379s
rm: temp/ZZZ*: No such file or directory
$ redis-cli -n 7 dbsize
(integer) 3840679
$ cut -f 1 -d '|' db/ripe.db | uniq |wc -l
 3861822
$ cut -f 1 -d '|' db/ripe.db | sort |uniq  |wc -l
 3840679

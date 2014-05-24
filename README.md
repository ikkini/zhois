# zhois

These tools help create a match between a (large) list of public IPs and whois data (inetnum/netname/country) found in RIPE.
Eventually I hope to convince the other NIC's to be as liberal with their information (or at least parts thereof) as RIPE is.
Also, it would be nice if abuse email addresses came in a fixed format so I could add these too.

## getdb.sh

A bash script to get the latest public RIPE database file and prepare it for parsing into a redis db. 
This method will probably move to ruby as well in the future.

## importips.rb

Nothing more than a way to quickly stash a large number of IPs into a Redis db.
Please note by default it first flushes db 6.

```
$ time ruby importips.rb

real	0m51.806s
user	0m47.203s
sys		0m0.594s

$ redis-cli -n 6 dbsize
(integer) 2179664
```

## importripe.rb

```
$ time ruby importripe.rb

real	13m19.395s
user	7m53.381s
sys		1m9.460s

$ redis-cli -n 7 dbsize
(integer) 6337676
```

This script adds the ripe information into Redis db 7. Again, please note it flushes db 7 before it starts adding. It will add three different sorted set types:

1.  Key=network address -> Value=broadcast address, score=rangesize, -> Value=[netname:<name>|country:<name>], score=rangesize.

2. Key=netname:<name>, Value=country:<name>, score=rangesize, Value=inetnum:<startip-stopip>, score=rangesize. 

3. Key=country:<name>, Value=netname:<name>, score=rangesize, Value=inetnum:<startip-stopip>, score=rangesize.

As the RIPE data is sometimes country,netname and sometimes netname,country, we cannot know its insertion order. Luckily, we do not care either.

I'm currently pipelining the `zadds`. This shaves four minutes from the non-pipelined version. I am guessing (but should verify) most time is spend  preparing the values for `zadd`-ing. 
 
## zhois.rb

```
$ time ruby zhois.rb

real    74m48.554s
user    40m48.304s
sys     12m8.748s
```
        
This script goes through the list of found IPs (db 6), creates a list of possible network addresses for that IP (with rangesizes) and looks those network address in the RIPE db (7). It stops on the smallest match (from /30 down to /8) and adds the match into db 1 as:

- Key=IP address, Value=rangesize, Value=country:<name>, Value=netname:<name> 

Again, the insertion order when it comes to country and netname is uncertain.

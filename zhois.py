#!/usr/bin/env python
"""
problems to be solved
1) minimize expensive (network) queries
2) list of semi-random integers (ip addresses).
   All integers belong to an associated range (inetnum).
   Place all integers within the minimum size
   correctly associated range.
3) minimize size in memory and on disk of data structures
4) return a database of all IP addresses with netnames and countries
Approach: hard problems first, build test based

tests/ contains:
    - iplist.db from zmap result.
    - ripe.db from download.

"""
workingdir = 'tests/'

### XXX debug/profile
from memory_profiler import profile
import datetime
startTime = datetime.datetime.now()

import subprocess
import socket
import struct
import os.path
import timeit
import pickle

try:
    import netaddr
except ImportError:
    print('get netaddr module')
    exit(1)

try:
    import csv
except ImportError:
    print('get csv module')
    exit(1)

try:
    import redis
except ImportError:
    print('get redis module')
    exit(1)

datum = datetime.datetime.now().strftime("%F")




#load ips, sort
@profile
def loadips(redisdb):
    r = redis.Redis(db=redisdb)
    ips = r.keys()
    return ips



@profile
def findRIPErange(ips):
    r = redis.Redis(db=7)
    for ip in ips:
        for cidr in reversed(range(8,32)):
            key = netaddr.IPNetwork(ip.decode("utf-8") + "/" + str(cidr)).network
            if r.exists(key):
                print(ip.decode("utf-8"),cidr,[i.decode("utf-8") for i in r.zrange(key, 1, 2)])
                break

ips = loadips(6)
findRIPErange(ips)
# XXX DEBUG
print(datetime.datetime.now()-startTime)

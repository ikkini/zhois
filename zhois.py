#!/usr/bin/env python3
"""
problems to be solved
1) minimize expensive (network) queries
2) list of semi-random integers.
   All integers belong to an associated range.
   Place all integers within the minimum number
   of correctly associated ranges.
3) minimize size in memory and on disk of data structures

Approach: hard problems first, build test based

tests/ contains:
    - iplist.db from zmap result.
    - ripe.db from download.

"""
### XXX debug/profile
from memory_profiler import profile

import subprocess
import socket
import struct
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


def run_command(command):
    p = subprocess.Popen(command, shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)
    return p.communicate()


def ip2int(addr):
    return struct.unpack("!I", socket.inet_aton(addr))[0]


def int2ip(addr):
    return socket.inet_ntoa(struct.pack("!I", addr))


#load ips, sort, into tuple
#@profile
def loadips(file):
    ips = [ip2int(i.strip()) for i in open(file)]
    ips.sort()
    ips = tuple(ips)
    return ips


@profile
def loadRIPEranges(file):
    inetnum = csv.reader(open(file), delimiter='|')
    netnum = []
    for row in inetnum:
        netnum.append([row[0], row[1], row[2]])
    print(netnum[len(netnum) - 1][0])
    print(len(netnum))


loadips('tests/iplist.db')
loadRIPEranges('db/ripe.db')

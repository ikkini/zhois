#!/usr/bin/env python
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
import datetime
startTime = datetime.datetime.now()

import subprocess
import socket
import struct
import os.path
import timeit

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
    import sqlite3
except ImportError:
    print('get sqlite3 module')
    exit(1)

datum = datetime.datetime.now().strftime("%F")


def run_command(command):
    p = subprocess.Popen(command, shell=True,
                         tdout=subprocess.PIPE,
                         tderr=subprocess.STDOUT)
    return p.communicate()


def ip2int(addr):
    return struct.unpack("!I", socket.inet_aton(addr))[0]


def int2ip(addr):
    return socket.inet_ntoa(struct.pack("!I", addr))


#load ips, sort, into tuple
@profile
def loadips(file):
    ips = [ip2int(i.strip()) for i in open(file)]
    ips.sort()
    ips = tuple(ips)
    return ips


@profile
def loadRIPEranges(file):
    """Once a day, if the ripe database does not exist, create one"""
    if not os.path.exists('tests/ripesql' + datum + '.db'):
        badranges = []
        conn = sqlite3.connect('tests/ripesql' + datum + '.db')
        c = conn.cursor()
        conn.commit()
        c.execute('''CREATE TABLE inetnum (ipmin integer,
                            ipmax integer, netname text, country
                            text) ''')
        inetnum = csv.reader(open(file), delimiter='|')
        for row in inetnum:
            badrow = {}
            try:
                ipmin = ip2int(row[0])
            except:
                try:
                    ipmin = row[0]
                    badrow['ipmin'] = ipmin
                except:
                    ipmin = None
                    badrow['ipmin'] = None

            try:
                ipmax = ip2int(row[1])
            except:
                try:
                    ipmax = row[1]
                    badrow['ipmax'] = ipmax
                except:
                    ipmax = None
                    badrow['ipmax'] = None
            try:
                netname = row[2]
            except:
                netname = None
                badrow['netname'] = None
            try:
                country = row[3][:2]
            except:
                country = None
                badrow['country'] = None
            if len(badrow) > 0:
                badranges.append(badrow)
            inet = (ipmin, ipmax, netname, country)
            c.execute('INSERT INTO inetnum VALUES (?,?,?,?)', inet)
        conn.commit()
        conn.close()
        print(badranges)

loadips('tests/iplist.db')
loadRIPEranges('tests/ripe.db')

# XXX DEBUG
print(datetime.datetime.now()-startTime)

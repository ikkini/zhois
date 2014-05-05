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


#load ips, sort
@profile
def loadips(file):
    ips = [ip2int(i.strip()) for i in open(file)]
    ips.sort()
    return ips


@profile
def createRIPEdb(file):
    """Once a day, if the ripe database does not exist, create one"""
    if not os.path.exists(workingdir + 'ripesql' + datum + '.db'):
        conn = sqlite3.connect(workingdir + 'ripesql' + datum + '.db')
        c = conn.cursor()
        c.execute('''CREATE TABLE inetnum (ipmin integer,
                            ipmax integer, netname text, country
                            text) ''')
        inetnum = csv.reader(open(file), delimiter='|')
        for row in inetnum:
            try:
                inet = (ip2int(row[0]), ip2int(row[1]), row[2], row[3][:2])
                c.execute('INSERT INTO inetnum VALUES (?,?,?,?)', inet)
            except Exception as e:
                print(row, e)
                continue
        conn.commit()
        conn.close()

# XXX below takes forever, no optimization yet
def findRIPErange(ips):
        conn = sqlite3.connect(workingdir + 'ripesql' + datum + '.db')
        c = conn.cursor()
        floorip = c.execute('SELECT min(ipmin) from inetnum')
        floorip = int(c.fetchone()[0])
        c.execute('SELECT max(ipmax) from inetnum')
        ceilip = int(c.fetchone()[0])
        for ip in ips:
            if floorip <= ip >= ceilip:
                for row in c.execute('''select "_ROWID_", "ipmin", "ipmax",
                                     "netname", "country" from inetnum where
                                     ipmin < ? and ipmax > ?''', (ip, ip)):
                    print(row[0], int2ip(row[1]), int2ip(row[2]),
                          row[3], row[4])
        conn.close()


ips = loadips(workingdir + 'iplist.db')
#createRIPEdb(workingdir + 'ripe.txt.src')
findRIPErange(ips)

# XXX DEBUG
print(datetime.datetime.now()-startTime)

#!/usr/bin/env python3
"""This tool is based on the work of the Cymru crew
(http://www.team-cymru.org/Services/ip-to-asn.html)
"""
import subprocess
import socket
import struct
try:
    import netaddr
except ImportError:
    print('get netaddr module')
    exit(1)


### XXX test
target = '8.8.8.8'


def run_command(command):
    p = subprocess.Popen(command, shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)
    return p.communicate()


def ip2int(addr):
    return struct.unpack("!I", socket.inet_aton(addr))[0]


def int2ip(addr):
    return socket.inet_ntoa(struct.pack("!I", addr))


### XXX test
cymruquery = "cat whois.txt"
#cymruquery = "whois -h v4.whois.cymru.com \" -p -f {0}\"".format(target)

for ip in run_command(cymruquery):
    print(ip)
    #ip = ''.join(ip[0].decode(encoding='utf-8').split()).split('|')
    print(ip)
#a = run_command(cymruquery)
#a = ''.join(a[0].decode(encoding='utf-8').split()).split('|')

### XXX test
#print(ip2int(a[1]))

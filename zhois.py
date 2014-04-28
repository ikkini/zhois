#!/usr/bin/env python3
import subprocess
import socket
import struct

"""This tool is based on the work of the Cymru crew (http://www.team-cymru.org/Services/ip-to-asn.html)
"""
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

cymruquery = "whois -h v4.whois.cymru.com \" -p -f {0}\"".format(target)
a = run_command(cymruquery)
a = ''.join(a[0].decode(encoding='utf-8').split()).split('|')

### XXX test
print(ip2int(a[1]))

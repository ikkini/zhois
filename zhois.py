#!/usr/bin/env python3
import subprocess

def run_command(command):
    p = subprocess.Popen(command, shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)
    return p.communicate()
# XXX test
target = '8.8.8.8'
cymruquery = "whois -h v4.whois.cymru.com \" -p -f {0}\"".format(target)
a = run_command(cymruquery)
a = ''.join(a[0].decode(encoding='utf-8').split()).split('|')
print(a)

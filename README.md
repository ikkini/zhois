# zhois
## A tool created to efficiently whois all hosts found with zmap


## some memory profiling

	sudo pip-3.2 install psutil
	sudo pip-3.2 install memory_profiler

set up memory profiling '''from memory_profiler import profile'''

	@profile
	def loadips(file):
	    ips = [ip2int(i.strip()) for i in open(file)]
	    ips.sort()
	    ips = tuple(ips)
	    del iplist
	    return ips

	loadips('tests/iplist')

	python3 -m memory_profiler zhois.py
	Filename: zhois.py

	Line #    Mem usage    Increment   Line Contents
	================================================
	    57     12.5 MiB      0.0 MiB   @profile
	    58                             def loadips(file):
	    59     35.1 MiB     22.6 MiB       ips = [ip2int(i.strip()) for i in open(file)]
	    60     35.7 MiB      0.6 MiB       ips.sort()
	    61     35.7 MiB      0.0 MiB       ips = tuple(ips)
	    62     35.7 MiB      0.0 MiB       return ips

	wc -l tests/iplist
	562807 tests/iplist
	@profile
	def loadips(file):
	    iplist = [ip2int(i.strip()) for i in open(file)]
	    iplist.sort()
	    ips = tuple(iplist)
	    del iplist
	    return ips

	loadips('tests/iplist')

	python3 -m memory_profiler zhois.py
	Filename: zhois.py

	Line #    Mem usage    Increment   Line Contents
	================================================
	    57     12.5 MiB      0.0 MiB   @profile
	    58                             def loadips(file):
	    59     35.1 MiB     22.6 MiB       iplist = [ip2int(i.strip()) for i in open(file)]
	    60     35.7 MiB      0.6 MiB       iplist.sort()
	    61     39.8 MiB      4.1 MiB       ips = tuple(iplist)
	    62     35.7 MiB     -4.1 MiB       del iplist
	    63     35.7 MiB      0.0 MiB       return ips

$ time ./zhois.py
Filename: ./zhois.py

Line #    Mem usage    Increment   Line Contents
================================================
    64     10.0 MiB      0.0 MiB   @profile
    65                             def loadips(file):
    66     49.7 MiB     39.7 MiB       ips = [ip2int(i.strip()) for i in open(file)]
    67     66.0 MiB     16.3 MiB       ips.sort()
    68     75.2 MiB      9.2 MiB       ips = tuple(ips)
    69     75.2 MiB      0.0 MiB       return ips


Filename: ./zhois.py

Line #    Mem usage    Increment   Line Contents
================================================
    72     23.7 MiB      0.0 MiB   @profile
    73                             def loadRIPEranges(file):
    74     23.7 MiB      0.0 MiB       if not os.path.exists('tests/ripesql' + datum + '.db'):
    75     23.9 MiB      0.1 MiB           conn = sqlite3.connect('tests/ripesql' + datum + '.db')
    76     23.9 MiB      0.0 MiB           c = conn.cursor()
    77     23.9 MiB      0.0 MiB           conn.commit()
    78     23.9 MiB      0.0 MiB           c.execute('''CREATE TABLE inetnum (ipmin integer,
    79                                                         ipmax integer, netname
    80     24.2 MiB      0.3 MiB                               text) ''')
    81     24.2 MiB      0.0 MiB           inetnum = csv.reader(open(file), delimiter='|')
    82     28.2 MiB      4.0 MiB           for row in inetnum:
    83     28.2 MiB      0.0 MiB               inet = (ip2int(row[0]),ip2int(row[1]),row[2])
    84     28.2 MiB      0.0 MiB               c.execute('INSERT INTO inetnum VALUES (?,?,?)', inet)
    85     28.0 MiB     -0.2 MiB           conn.commit()
    86     28.0 MiB      0.0 MiB           conn.close()



real	6m21.747s
user	5m24.080s
sys	0m57.143s

creating the dataset with minip,maxip,netname,country
time ./getdb.sh

real	2m0.993s
user	3m37.865s
sys	0m4.650s

# Added input validation. Suddenly my time goes up to about 22 minutes. Meh.
Instead I've contacted RIPE and they fixed the incorrect fields (inetnum). 
I've also tried to use sqlite3 from the CLI. No inet_ntoa etc. conversion, but works really efficient from getdb.sh.
Works mucho better.

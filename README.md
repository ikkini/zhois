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


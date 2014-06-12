# encoding: UTF-8
require 'hiredis'
require 'redis'
require 'netaddr'

# Connect to Redis databases.
# 6 contains found IPs.
# 7 contains zsets: k:first inetnum, v=last inetnum, score=networksize,
#   v=netname, score=networksize, v=country, score=networksize.
iplist = Redis.new(db: 6, driver: 'hiredis')
ripe = Redis.new(db: 7, driver: 'hiredis')
results = Redis.new(db: 1, driver: 'hiredis')

# Flush the results database
puts 'flush the results database'
results.flushdb

puts 'Iterate over iplist keys'
iplist.keys.each do |ip|
  netaddrlist = []
  # RIPE DB 7 does not contain any subnet larger than a /8 and RIPE should
  #    not have any CIDR larger than a /30.
  30.downto(8) do |mask|
    netaddr = NetAddr::CIDRv4.create("#{ip}/#{mask}")
    # Use NetAddr to create pairs of network address and subnet size.
    netaddrlist << [netaddr.first, netaddr.size, netaddr.last]
  end
  netaddrlist.each do |naddr|
    # OPTIMIZE: How to make this cheaper?
    # below assumes we know what is at a[1] (country, cause it starts
    # with a c) and a[2] (netname)
    a = ripe.zrangebyscore(naddr[0], naddr[1], naddr[1])
    next unless a.size == 3
    # Insert 4 record types per match: ip:, inetnum:, country:, and netname:.
    # Each of these contains the others, everything sorted (zadd score) by
    # iprangesize.
    #
    results.multi do
      # it adds a fraction extra time to the parsing to assign these to
      # readable values
      inetnum = 'inetnum:' + naddr[0] + '-' + naddr[2]
      country = a[1]
      netname = a[2]
      netrange = naddr[1]
      results.zadd(inetnum, [[netrange, 'ip:' + ip], [netrange, country],
                             [netrange, netname]])
      results.zadd(country, [[netrange, 'ip:' + ip], [netrange, netname],
                             [netrange, inetnum]])
      results.zadd(netname, [[netrange, 'ip:' + ip], [netrange, country],
                             [netrange, inetnum]])
      results.zadd('ip:' + ip, [[netrange, netname], [netrange, country],
                                [netrange, inetnum]])
      results.sadd('index:ip', ip)
      results.sadd('index:inetnum', inetnum)
      results.sadd('index:country', country)
      results.sadd('index:netname', netname)
    end
  end
end

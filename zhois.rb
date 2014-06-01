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
  # RIPE DB 7 does not contain anything larger than a /8 and RIPE should
  #    not have anything larger than a /30.
  30.downto(8) do |mask|
    netaddr = NetAddr::CIDRv4.create("#{ip}/#{mask}")
    # Use NetAddr to create pairs of network address and subnet size.
    netaddrlist << [netaddr.first, netaddr.size, netaddr.last]
  end
  netaddrlist.each do |naddr|
    # First test for existence. This means two roundtrips.
    # OPTIMIZE: How to make this cheaper?
    a = ripe.zrangebyscore(naddr[0], naddr[1], naddr[1])
    next unless a.size == 3
    # Insert 4 record types per match: ip:, inetnum:, netname:, and country:.
    # Each of these contains the others, everything sorted (zadd score) by
    # iprangesize.
    #
    results.multi do
      results.zadd('inetnum:' + naddr[0] + '-' + naddr[2],
                   [[naddr[1], 'ip:' + ip], [naddr[1], a[1]], [naddr[1], a[2]]])
      results.zadd(a[1], [[naddr[1], 'ip:' + ip], [naddr[1], a[2]],
                          [naddr[1], 'inetnum:' + naddr[0] + '-' + naddr[2]]])
      results.zadd(a[2], [[naddr[1], 'ip:' + ip], [naddr[1], a[1]],
                          [naddr[1], 'inetnum:' + naddr[0] + '-' + naddr[2]]])
      results.zadd('ip:' + ip, [[naddr[1], a[2]], [naddr[1], a[1]],
                                [naddr[1], 'inetnum:' + naddr[0] + '-' +
                                 naddr[2]]])
    end
  end
end

# encoding: UTF-8
require 'hiredis'
require 'redis'
require 'netaddr'

# Connect to Redis databases.
# 6 contains found IPs.
# 7 contains zsets: k:first inetnum, v=last inetnum, score=networksize,
#   v=netname, score=networksize, v=country, score=networksize.
zmappedips = Redis.new(db: 6, driver: 'hiredis')
ripe = Redis.new(db: 7, driver: 'hiredis')
whois = Redis.new(db: 1, driver: 'hiredis')

zmappedips.keys.each do |ip|
  netaddrlist = []
  # RIPE DB 7 does not contain anything larger than a /8 and RIPE should
  #    not have anything larger than a /30.
  30.downto(8) do |mask|
    netaddr = NetAddr::CIDRv4.create("#{ip}/#{mask}")
    # Use NetAddr to create pairs of network address and subnet size.
    netaddrlist << [netaddr.first, netaddr.size]
  end
  netaddrlist.each do |naddr|
    # First test for existence. This means two roundtrips.
    if ripe.zcount(naddr[0], naddr[1], naddr[1]) == 3
      # zrangebyscore, score is subnet size, find smallest subnet
      #     + country & netname
      a = ripe.zrangebyscore(naddr[0], naddr[1], naddr[1])
      # push match to the redis whois table (1)
      whois.rpush(ip, [naddr[1], a[1], a[2]])
      break
    end
  end
end

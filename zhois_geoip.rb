# encoding: UTF-8
require 'hiredis'
require 'redis'
require 'netaddr'

# Connect to Redis databases.
# 6 contains found IPs.
# 7 contains zsets: k:first inetnum, v=last inetnum, score=networksize,
#   v=netname, score=networksize, v=country, score=networksize.
geoip = Redis.new(db: 1, driver: 'hiredis')
iplist = Redis.new(db: 2, driver: 'hiredis')
results = Redis.new(db: 3, driver: 'hiredis')

# Flush the results database
puts 'flush the results database'
results.flushdb

country = geoip.lindex('index:geoip', 0).split(':')

puts "#{country[0].to_i} #{country[1].to_i} #{country[2]}"
#puts 'Iterate over iplist keys'
#iplist.lrange('index:iplist',0,-1).each do |ip|
#  iplist.get(ip)
#end

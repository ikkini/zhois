# encoding: UTF-8
require 'hiredis'
require 'redis'
require 'netaddr'

# Connect to Redis databases.
geoip = Redis.new(db: 1, driver: 'hiredis')
#
# because of how we currently create the geoipmatrix, we need to pop the
# first instance
geoip.lpop('index:geoip')

# see if ip in country
#   if yes store ip+ pop ip + get next ip
#   not, pop country and get next country
until geoip.llen('index:iplist') == 0
  ipaddress = geoip.lindex('index:iplist', 0)
  country = geoip.lindex('index:geoip', 0).split(':')
  if ipaddress.to_i <= country[1].to_i
    foundip = geoip.lpop('index:iplist')
    # puts "popping #{foundip}: found in #{country}"
    geoip.rpush('res:' + country[2], NetAddr.i_to_ip(foundip.to_i, Version: 4))
  else
    geoip.lpop('index:geoip')
    # puts "popping #{geoiprange}"
  end
end

# Encoding: utf-8
require 'csv'
require 'netaddr'
require 'hiredis'
require 'redis'

ripe = Redis.new(db: 7, driver: 'hiredis')
ripe.flushdb
CSV.foreach('src/ripe.formatted.src', col_sep: '|') do |row|
  networkip = row[0].lstrip
  broadcastip = row[1]
  iprangesize = NetAddr.range(networkip, broadcastip, Inclusive: true, Size: true)
  # skip any range above a /8
  if iprangesize < 16_777_216
    # split rows and convert to correct lower:UPPER format
    v2 = row[2].split(':')
    v3 = row[3].split(':')
    v2 = v2[0] << ':' << v2[1].upcase
    v3 = v3[0] << ':' << v3[1].rstrip.upcase
    ripe.zadd(networkip, [[iprangesize, broadcastip], [iprangesize, v2], [iprangesize, v3]])
    #ripe.zadd(v2, iprangesize, v3)
    #ripe.zadd(v3, iprangesize, v2)
  end
end

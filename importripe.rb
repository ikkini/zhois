# Encoding: utf-8
require 'csv'
require 'netaddr'
require 'hiredis'
require 'redis'

# added longer timeout, otherwise flushdb results in TimeoutErrors
ripe = Redis.new(db: 7, driver: 'hiredis', timeout: 20)
ripe.flushdb
CSV.foreach('src/ripe.formatted.src', col_sep: '|') do |row|
  networkip = row[0].lstrip
  broadcastip = row[1]
  iprangesize = NetAddr.range(networkip, broadcastip,
                              Inclusive: true, Size: true)
  # Skip any range above a /8.
  if iprangesize < 16_777_216
    # Split rows and convert to lower:UPPER format.
    # This correct errors in netnames and country names.
    # Current shellscript leaves whitespaces before and after.
    v2 = row[2].split(':')
    v3 = row[3].split(':')
    v2 = v2[0] << ':' << v2[1].upcase
    v3 = v3[0] << ':' << v3[1].rstrip.upcase
    # (Re)Create an inetnum entry for storing in countries and netnames
    inetnum = 'inetnum:' << networkip << '-'  << broadcastip
    # And create sorted sets with each value as a key.
    ripe.pipelined do
      ripe.zadd(networkip, [[iprangesize, broadcastip],
                            [iprangesize, v2],
                            [iprangesize, v3]])
      ripe.zadd(v2, [[iprangesize, v3], [iprangesize, inetnum]])
      ripe.zadd(v3, [[iprangesize, v2], [iprangesize, inetnum]])
    end
  end
end

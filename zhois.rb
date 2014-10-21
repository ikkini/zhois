# Encoding: utf-8
require 'csv'
require 'netaddr'
require 'hiredis'
require 'redis'

# added longer timeout, otherwise flushdb results in TimeoutErrors
geoip = Redis.new(db: 1, driver: 'hiredis', timeout: 30)
#synip = Redis.new(db: 2, driver: 'hiredis', timeout: 30)
rsyncip = Redis.new(db: 3, driver: 'hiredis', timeout: 30)
#puts 'Flushing dbs'
geoip.flushdb
#synip.flushdb
rsyncip.flushdb
puts 'Adding network(int):broadcast(int):CC GeoIP values to index:geoip'

# use geoip/create.sh
CSV.foreach('geoip/geoipmatrix.csv', col_sep: ',') do |row|
  unless row[2].to_i == 0
    if row[2].to_i - row[9].to_i > 1
      # Add skipped range as an added row.
      geoip.rpush('index:geoip', ((row[8].to_i - 1) +
                                  (row[2].to_i - row[9].to_i)).to_s +
                                  ':' + (row[2].to_i - 1).to_s + ':SKIP')
      # Add actual row
      geoip.rpush('index:geoip', row[2] + ':' + row[3] + ':' + row[4])
    else
      geoip.rpush('index:geoip', row[2] + ':' + row[3] + ':' + row[4])
    end
  end
end
# sorted list, using sort -t . -n -k 1,1n -k 2,2n -k 3,3n -k 4,4n
#puts 'Adding "sorted ip_to_i" found IPs responding to syn to index:synip'
#CSV.foreach('src/synip') do |row|
#  synip.rpush('index:synip', NetAddr.ip_to_i(row[0], Version: 4))
#end
puts 'Adding "sorted ip_to_i" found IPs with actual rsync responses to index:rsyncip'
CSV.foreach('src/rsyncip') do |row|
  rsyncip.rpush('index:rsyncip', NetAddr.ip_to_i(row[0], Version: 4))
end


# because of how we currently create the geoipmatrix, we need to pop the
# first instance
geoip.lpop('index:geoip')

# see if rsyncip in country
#   if yes store rsyncip + pop rsyncip + get next rsyncip
#   if not, pop country and get next country
until rsyncip.llen('index:rsyncip') == 0
  ipaddress = rsyncip.lindex('index:rsyncip', 0)
  country = geoip.lindex('index:geoip', 0).split(':')
  if ipaddress.to_i <= country[1].to_i
    foundip = rsyncip.lpop('index:rsyncip')
    #puts "popping #{foundip}: found in #{country}"
    rsyncip.rpush('res:' + country[2], NetAddr.i_to_ip(foundip.to_i, Version: 4))
  else
    geoip.lpop('index:geoip')
    #puts "popping #{geoiprange}"
  end
end

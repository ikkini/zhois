# Encoding: utf-8
require 'csv'
require 'netaddr'
require 'hiredis'
require 'redis'

# added longer timeout, otherwise flushdb results in TimeoutErrors
geoip = Redis.new(db: 1, driver: 'hiredis', timeout: 30)
puts 'Flushing geoip db'
geoip.flushdb
puts 'Adding network(int):broadcast(int):CC GeoIP values to index:geoip'

# Paste -d ',' geoip.csv geoip2.csv > geoipmatrix.csv
# Add approriate '0' fields to end of geoip and beginning of geoip2
#   before you do this.
CSV.foreach('geoip/geoipmatrix', col_sep: ',') do |row|
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
# sort -n -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4
puts 'Adding "sorted ip_to_i" found IP values to index:iplist'
CSV.foreach('src/iplist') do |row|
  geoip.rpush('index:iplist', NetAddr.ip_to_i(row[0], Version: 4))
end

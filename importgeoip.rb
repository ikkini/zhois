# Encoding: utf-8
require 'csv'
require 'netaddr'
require 'hiredis'
require 'redis'

# added longer timeout, otherwise flushdb results in TimeoutErrors
geoip = Redis.new(db: 1, driver: 'hiredis', timeout: 30)
puts "flushing geoip db"
geoip.flushdb
puts "adding networkaddr:broadcastaddr:countrycode values to index:geoip"
lowest = [0]

# Paste -d ',' geoip.csv geoip2.csv > geoipmatrix.csv
# Add approriate "0" fields to end of geoip and beginning of geoip2
#   before you do this.
CSV.foreach('geoip/geoipmatrix.csv', col_sep: ',') do |row|
  unless row[2].to_i == 0
    if row[2].to_i - row[9].to_i > 1
      # Add skipped range as an added row.
      geoip.rpush('index:geoip', ((row[8].to_i - 1) + (row[2].to_i - row[9].to_i)).to_s + ':' + (row[2].to_i - 1).to_s + ":SKIP")
      # Add actual row
      geoip.rpush('index:geoip', row[2] + ':' + row[3] + ':' +row[4])
    else
      geoip.rpush('index:geoip', row[2] + ':' + row[3] + ':' +row[4])
    end
  end
end
iplist = Redis.new(db: 2, driver: 'hiredis')
puts "flushing iplist db"
iplist.flushdb
puts "adding ip->ip_to_i values"
# sorted list, using sort -t . -n -k 1,1n -k 2,2n -k 3,3n -k 4,4n
CSV.foreach('src/iplist') do |row|
  iplist.rpush('index:iplist', row[0])
  iplist.set(row[0], NetAddr.ip_to_i(row[0], :Version => 4))
end

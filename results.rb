# encoding: UTF-8
require 'hiredis'
require 'redis'

# Connect to Redis databases and print "," formatted to stdout
results = Redis.new(db: 1, driver: 'hiredis')

results.keys.each do |ip|
  puts "#{ip}," << results.lrange(ip, 0, -1).join(',')
end

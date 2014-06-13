# encoding: UTF-8
require 'hiredis'
require 'redis'

# Connect to Redis databases and print "," formatted to stdout
results = Redis.new(db: 1, driver: 'hiredis')

ARGV.each do |arg|
puts arg

results.smembers('index:' + "#{arg}").each do |zkey|
  puts '[\'' + "#{zkey.sub(arg + ':', '')}'," << results.zcard(zkey).to_s + ']'
end
end

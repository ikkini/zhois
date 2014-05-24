# Encoding: utf-8
require 'csv'
require 'hiredis'
require 'redis'

iplist = Redis.new(db: 6, driver: 'hiredis')
iplist.flushdb
CSV.foreach('src/zmapped') do |row|
  iplist.set(row[0], row[0])
end

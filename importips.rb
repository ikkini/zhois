# Encoding: utf-8
require 'csv'
require 'hiredis'
require 'redis'

iplist = Redis.new(db: 6, driver: 'hiredis')
iplist.flushdb
iplist.pipelined do
  CSV.foreach('src/iplist') do |row|
    iplist.set(row[0], row[0])
  end
end

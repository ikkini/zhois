# Encoding: utf-8
require 'csv'
require 'hiredis'
require 'redis'

zmappedips = Redis.new(db: 6, driver: 'hiredis')
zmappedips.flushdb
CSV.foreach('src/zmapped') do |row|
  zmappedips.set(row[0], row[0])
end

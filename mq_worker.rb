require 'iron_mq'
require 'redis'
require 'memcache'
require 'quicky'

puts "Payload: #{params}"

options = params['options']
puts 'options: ' + options.inspect

times = 100

quicky = Quicky::Timer.new()

@ic = IronMQ::Client.new(:token=>options['token'], :project_id=>options['project_id'])
queue = @ic.queue("my_cache")
quicky.loop("iron_http PUT", times, :warmup=>3) do |i|
  queue.post("hello world!")
end
quicky.loop("iron_http GET", times, :warmup=>3) do |i|
  queue.get()
end

#
#puts "REDIS"
#roptions = params['redis_options'].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
#p roptions
#redis = Redis.new(roptions)
#quicky.loop("redistogo SET", times, :warmup=>3) do |i|
#  redis.set("test", "value")
#end
#quicky.loop("redistogo GET", times, :warmup=>3) do |i|
#  redis.get("test")
#end
#
#puts "IronCache Memcached"
#mc = MemCache.new(['cache-aws-us-east-1.iron.io:11211'])
#mc.set("oauth", "#{options['token']} #{options['project_id']} my_memcached_cache", 0, true)
#quicky.loop("iron_memcached SET", times, :warmup=>3) do |i|
#  mc.set("test", "value")
#end
#quicky.loop("iron_memcached GET", times, :warmup=>3) do |i|
#  mc.get("test")
#end

quicky.results.each_pair do |k, v|
  puts "#{k}: #{v.duration}"
end

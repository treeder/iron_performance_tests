require 'iron_mq'
require 'redis'
require 'memcache'
require 'quicky'
require 'aws-sdk'

puts "Payload: #{params}"
options = params['options']
config = params[:config]

times = 1000

quicky = Quicky::Timer.new()

@ic = IronMQ::Client.new(:token => options['token'], :project_id => options['project_id'])
queue = @ic.queue("my_cache")
quicky.loop("iron_http PUT", times, :warmup => 3) do |i|
  queue.post("hello world!")
end
quicky.loop("iron_http GET", times, :warmup => 3) do |i|
  m = queue.get()
end

# todo: use redis as queue
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
# todo: use IronMQ beanstalkd interface
#puts "IronCache Memcached"
#mc = MemCache.new(['cache-aws-us-east-1.iron.io:11211'])
#mc.set("oauth", "#{options['token']} #{options['project_id']} my_memcached_cache", 0, true)
#quicky.loop("iron_memcached SET", times, :warmup=>3) do |i|
#  mc.set("test", "value")
#end
#quicky.loop("iron_memcached GET", times, :warmup=>3) do |i|
#  mc.get("test")
#end

# todo: add SQS
sqs = AWS::SQS.new(
    :access_key_id => config[:aws][:access_key],
    :secret_access_key => config[:aws][:secret_key]
)
queue = sqs.queues.create("test_perf")

quicky.loop("sqs PUT", times, :warmup => 3) do |i|
  queue.send_message("hello world!")
end
quicky.loop("sqs GET", times, :warmup => 3) do |i|
  msg = queue.receive_message()
  puts "Got message: #{msg.body}"
end

quicky.results.each_pair do |k, v|
  puts "#{k}: Count: #{v.count} Total: #{v.total_duration} Avg: #{v.duration} Max: #{v.max_duration} Min: #{v.min_duration}"
end

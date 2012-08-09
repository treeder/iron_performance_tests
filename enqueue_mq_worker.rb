require "iron_worker_ng"
require 'iron_cache'
require 'redis'
require 'uber_config'

config = UberConfig.load
config = UberConfig.symbolize_keys!(config)
p config
p config[:redistogo]
p config[:redistogo][:host]

redis = Redis.new(config[:redistogo])
redis.set("test", "value")

tasks = []
client = IronWorkerNG::Client.new
1.times do |i|
  puts "#{i} queueing task"
  tasks << client.tasks.create("mq", "options" => client.api.options, "redis_options"=>config[:redistogo], :config=>config)
end

tasks.each_with_index do |task, i|
  puts "Waiting for task #{i}"
  status = client.tasks.wait_for(task.id)
  puts status.status
  log = client.tasks.log(task.id)
  puts log
end

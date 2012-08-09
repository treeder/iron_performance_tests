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

client = IronWorkerNG::Client.new
1.times do
  client.tasks.create("cache", "options" => client.api.options, "redis_options"=>config[:redistogo])
end

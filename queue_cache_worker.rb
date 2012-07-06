require "iron_worker_ng"
require 'iron_cache'
require 'redis'

redis_options = {:host => "filefish.redistogo.com",
                 :port => 9272,
                 :username => "treeder",
                 :password => "b5e2db3a188046576e77761a29937097"}
redis = Redis.new(redis_options)

redis.set("test", "value")

client = IronWorkerNG::Client.new
1.times do
  client.tasks.create("cache_worker", "options" => client.api.options, "redis_options"=>redis_options)
end

require 'sinatra'
require 'logger'
require File.join(File.dirname(__FILE__), 'app', 'redis.rb')

configure :development, :test do
  require 'dotenv'
  Dotenv.load
end

configure :production do
  require 'newrelic_rpm'
end

get '/' do
  erb :index
end

get '/ponpe.json' do
  redis   = Ponpetter::Redis.connect
  {
     tweets: Marshal.load(redis.get("tweets")),
     ponpe_cnt: redis.get('ponpe-cnt'),
     graph: {
       labels:redis.lrange('graph-labels', -30, -1),
       values:redis.lrange('graph-values', -30, -1)
     }
  }.to_json
end


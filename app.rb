require 'sinatra'
require 'logger'
require 'unicorn'
require File.join(File.dirname(__FILE__), 'app', 'redis.rb')

configure :development, :test do
  require 'dotenv'
  Dotenv.load
end

# root
get '/' do

  redis   = Ponpetter::Redis.connect
  @tweets = Marshal.load(redis.get("tweets"))
  @ponpe_cnt = redis.get('ponpe-cnt')
  @graph = {
    labels:redis.zrange('graph-labels', 0, -1),
    values:redis.zrange('graph-values', 0, -1)
  }

  erb :index
end



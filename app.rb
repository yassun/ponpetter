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
    labels:redis.lrange('graph-labels', 0, 30),
    values:redis.lrange('graph-values', 0, 30)
  }

  erb :index
end



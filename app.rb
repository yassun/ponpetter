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

  # redisに接続
  redis = Ponpetter::Redis.connect
  @tweets = Marshal.load(redis.get("tweets"))

  erb :index
end



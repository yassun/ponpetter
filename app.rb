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

  redis = Ponpetter::Redis.connect
  @tweets = Marshal.load(redis.get("tweets"))

  @today = Date.today.to_s
  @ponpe_cnt = redis.get(@today)

  erb :index
end



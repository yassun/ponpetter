require File.dirname(__FILE__) + '/app.rb'
require 'eventmachine'
require File.join(File.dirname(__FILE__), 'app', 'scheduler.rb')
require File.join(File.dirname(__FILE__), 'app', 'redis.rb')

$stdout.sync = true

run Sinatra::Application

Thread.new do
  redis = Ponpetter::Redis.connect
  EM.defer do
    loop do
      sleep 15
      begin
        puts "execute Scheduler"
        Ponpetter::Scheduler.execute(redis)
      rescue Twitter::Error::TooManyRequests => e
        puts "sleep #{e.rate_limit.reset_in}s <- #{e.inspect} #{e.backtrace}"
        sleep e.rate_limit.reset_in
        retry
      rescue => e
        puts "ERROR! <- #{e.inspect}"
      end
    end
  end
end

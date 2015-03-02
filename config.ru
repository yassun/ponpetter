require File.dirname(__FILE__) + '/app.rb'
require 'eventmachine'
require File.join(File.dirname(__FILE__), 'app', 'scheduler.rb')

run Sinatra::Application

EM::defer do
  loop do
    sleep 15
    begin
      Ponpetter::Scheduler.execute
    rescue Twitter::Error::TooManyRequests => e
      puts "sleep #{e.rate_limit.reset_in}s <- #{e.inspect} #{e.backtrace}"
      sleep e.rate_limit.reset_in
      retry
    rescue => e
      puts "ERROR! <- #{e.inspect}"
    end
  end
end

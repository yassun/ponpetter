require File.join(File.dirname(__FILE__), 'app', 'tweet_search.rb')
require File.join(File.dirname(__FILE__), 'app', 'scheduler.rb')
require File.join(File.dirname(__FILE__), 'app', 'redis.rb')
require 'dotenv'
Dotenv.load

task :scheduler_execute do
  Ponpetter::Scheduler.execute
end

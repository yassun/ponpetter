require File.dirname(__FILE__) + '/app.rb'
require 'eventmachine'
require File.join(File.dirname(__FILE__), 'app', 'scheduler.rb')

run Sinatra::Application

EM::defer do
  loop do
    sleep 15
    Ponpetter::Scheduler.execute
  end
end

require File.join(File.dirname(__FILE__), '..', 'app.rb')
require File.join(File.dirname(__FILE__), '..', 'app', 'scheduler.rb')
require File.join(File.dirname(__FILE__), '..', 'app', 'redis.rb')

require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
require 'mock_redis'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false


require File.join(File.dirname(__FILE__), '..', 'app.rb')
require File.join(File.dirname(__FILE__), '..', 'app', 'tweet_search.rb')
require File.join(File.dirname(__FILE__), '..', 'app', 'scheduler.rb')
require File.join(File.dirname(__FILE__), '..', 'app', 'redis.rb')

require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'mock_redis'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

Capybara.default_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
                    js_errors: false,
                    timeout: 1000,
                    phantomjs_options: [
                              '--load-images=no',
                              '--ignore-ssl-errors=yes',
                              '--ssl-protocol=any'],
                    inspector: true,
                    })
end



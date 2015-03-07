require File.join(File.dirname(__FILE__), '..','app', 'scheduler.rb')
require File.join(File.dirname(__FILE__), '..','app', 'redis.rb')
require 'eventmachine'
require 'faye/websocket'
require 'json'

Faye::WebSocket.load_adapter('thin')

module Ponpetter
  class Backend
    KEEPALIVE_TIME = 15

    def initialize(app)
      @app = app
      @clients = []
      scheduler_thread
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, ping: KEEPALIVE_TIME)

        ws.on :open do |event|
          @clients << ws
        end

        ws.on :close do |event|
          @clients.delete(ws)
          @clients.compact!
          ws = nil
        end

        ws.rack_response
      else
        @app.call(env)
      end
    end

    def scheduler_thread
      Thread.new do
        redis = Ponpetter::Redis.connect
        EM.defer do
          loop do
            sleep 15
            begin
              puts "execute Scheduler"
              Ponpetter::Scheduler.execute(redis)
              send_ponpe_data(redis)
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
    end

    def send_ponpe_data(redis)
      data = {
        tweets: Marshal.load(redis.get("tweets")),
        ponpe_cnt: redis.get('ponpe-cnt'),
      }
      @clients.each do |ws|
        ws.send(data.to_json) if ws
      end
    end

  end
end


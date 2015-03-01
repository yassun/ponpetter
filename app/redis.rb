require 'redis'

module Ponpetter
  module Redis
    def self.connect
      if ENV["REDISTOGO_URL"] != nil
          uri = URI.parse(ENV["REDISTOGO_URL"])
          ::Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      else
          ::Redis.new host:"127.0.0.1", port:"6379"
      end
    end
  end
end


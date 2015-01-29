require 'redis'

module Ponpetter
  module Redis
    def self.connect
      ::Redis.new(param)
    end

    private

    def self.param
      {
        host: ENV["REDIS_HOST"],
        port: ENV["REDIS_PORT"]
      }
    end
  end
end


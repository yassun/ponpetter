require 'twitter'

module Ponpetter
  class TweetSearch
    def initialize
      @client = client
    end

    private
    def client
      Twitter::REST::Client.new do |config|
        config.consumer_key = ENV["TW_CONSUMER_KEY"]
        config.consumer_secret = ENV["TW_CONSUMER_SECRET"]
        config.access_token = ENV["TW_ACCESS_TOKEN"]
        config.access_token_secret = ENV["TW_ACCESS_SECRET"]
      end
    end

  end
end

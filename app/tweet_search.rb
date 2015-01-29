require 'twitter'

module Ponpetter
  class TweetSearch
    KEYWORD = '腹痛 OR お腹痛い OR ポンペ OR ぽんぺ OR #ponponpain OR #ponpetter -filter:retweets'

    def initialize(since_id)
      @since_id = since_id
      @client   = client
    end

    def run
      client.search(KEYWORD, result_type: 'recent', since_id: @since_id).take(100).to_a.reverse.map do |tweet|
        {
          id: tweet.id,
          img: tweet.user.profile_image_url,
          autor: tweet.user.screen_name,
          text: tweet.text,
          time: tweet.created_at,
        }
      end
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

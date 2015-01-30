require "date"
require File.dirname(__FILE__) + '/tweet_search.rb'

module Ponpetter
  class Scheduler
    def self.execute

      # redisに接続
      redis = Ponpetter::Redis.connect

      # since_idを取得
      since_id = redis.get("since_id") || 0

      # tweetの更新
      tweets = TweetSearch.new(since_id).run
      redis.set("tweets", tweets)

      # ポンペ数の更新
      today = Date.today.to_s
      ponpe_cnt = redis.get(today) || 0
      ponpe_cnt = ponpe_cnt.to_i + tweets.length
      redis.set(today, ponpe_cnt)

      # since_idの更新
      since_id = tweets.last[:id] || 0
      redis.set("since_id", since_id)

    end
  end
end


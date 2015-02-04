require "date"
require File.dirname(__FILE__) + '/tweet_search.rb'

module Ponpetter
  class Scheduler
    def self.execute

      # redisに接続
      redis = Ponpetter::Redis.connect

      # since_idを取得
      since_id = redis.get('since_id') || 0

      # tweetの更新
      tweets = TweetSearch.new(since_id).run
      redis.set("tweets",  Marshal.dump(tweets))

      # ポンペ数の更新
      ponpe_cnt = redis.get('ponpe-cnt') || 0
      ponpe_cnt = ponpe_cnt.to_i + tweets.length
      redis.set('ponpe-cnt', ponpe_cnt)

      # since_idの更新
      since_id = tweets.first[:id] || 0
      redis.set('since_id', since_id)

    end
  end
end


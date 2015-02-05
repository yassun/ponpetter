require "date"
require File.dirname(__FILE__) + '/tweet_search.rb'

module Ponpetter
  class Scheduler
    def self.execute

      # redisに接続
      redis = Ponpetter::Redis.connect

     # 処理日付の取得
      today = Date.today.to_s

      # 前回処理日付の取得
      last_date = redis.get('last-date') || today

      # 日替わり発生時
      unless last_date == today

        # ポンペ数をグラフデータに移動
        time_stamp = Time.now.to_i
        ponpe_cnt = redis.get('ponpe-cnt')
        redis.zadd('graph-labels', time_stamp, last_date)
        redis.zadd('graph-values', time_stamp, ponpe_cnt)

        # ポンペ数を初期化
        redis.set('ponpe-cnt', 0)

        # 処理日付の変更
        redis.set('last_date', today)

      end

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


require "date"
require File.dirname(__FILE__) + '/tweet_search.rb'

module Ponpetter
  class Scheduler
    MAX_COUNT = 365
    def self.execute(redis)
     # 処理日付の取得
      today = Date.today.to_s

      # 前回処理日付の取得
      last_date = redis.get('last-date') || today

      # 日替わり発生時
      if last_date != today

        # ポンペ数をグラフデータに移動
        ponpe_cnt = redis.get('ponpe-cnt')
        redis.rpush('graph-labels', last_date)
        redis.rpush('graph-values', ponpe_cnt)

        # ポンペ数を初期化
        redis.set('ponpe-cnt', 0)

        # 最大格納数を超える場合は一番古いデータを削除
        if trim_start_index = redis.llen('graph-labels') - MAX_COUNT
          redis.ltrim('graph-labels', trim_start_index, MAX_COUNT - 1)
          redis.ltrim('graph-values', trim_start_index, MAX_COUNT - 1)
        end
      end

      # since_idを取得
      since_id = redis.get('since-id') || 0

      # tweetの取得
      new_tweets = TweetSearch.new(since_id).run

      # ポンペ数の更新
      ponpe_cnt = redis.get('ponpe-cnt') || 0
      ponpe_cnt = ponpe_cnt.to_i + new_tweets.length
      redis.set('ponpe-cnt', ponpe_cnt)

      # tweetの更新(最新100件のみ表示)
      old_tweets = []
      if redis.get("tweets")
        old_tweets = Marshal.load(redis.get("tweets"))
      end
      new_tweets += old_tweets
      redis.set("tweets",  Marshal.dump(new_tweets.first(100)))

      # since_idの更新
      since_id = new_tweets.first[:id] || ENV["INIT_SINCE_ID"]
      redis.set('since-id', since_id)

      # 処理日付の変更
      redis.set('last-date', today)

    end
  end
end


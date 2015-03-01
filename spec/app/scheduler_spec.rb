require File.dirname(__FILE__) + '/../spec_helper'

describe "Scheduler" do
  let(:mr){ MockRedis.new }
  let(:tweets) {
      [{
        id: 1234567890,
        img: "http://pbs.twimg.com/profile_images/img/xxxxx.jpeg",
        autor: "hoge",
        text: "お腹痛い",
        time: "2015-02-01 16:57:17 +0900"
      }]
  }

  before do
    # today
    allow(Date).to receive(:today).and_return(Date.new(2015, 2, 1))

    # redis
    allow(Ponpetter::Redis).to receive(:connect).and_return(mr)
    mr.set('tweets',Marshal.dump(tweets))

    # twitter
    twitter_client_mock = double('Twitter client')
    allow(twitter_client_mock).to receive(:run).and_return(tweets)
    allow(Ponpetter::TweetSearch).to receive(:new).and_return(twitter_client_mock)

  end

  describe "#execute" do

    context "日替わり未発生" do
      before do
        Ponpetter::Scheduler.execute
      end

      it "前回処理日付に今日の日付が設定されていること" do
        expect(mr.get('last-date')).to eq "2015-02-01"
      end

      it "since_idが更新されていること" do
        expect(mr.get('since-id')).to eq "1234567890"
      end

      it "tweetが追加保存されていること" do
        append = tweets + tweets
        expect(Marshal.load(mr.get('tweets'))).to eq append
      end

      it "ポンペ数が更新されていること" do
        expect(mr.get('ponpe-cnt')).to eq "1"
      end
    end

    context "日替わり発生時" do

      context "グラフデータ格納最大数を超えていない場合" do
        before do
          mr.set('last-date','2014-01-31')
          mr.set('ponpe-cnt','100')
          Ponpetter::Scheduler.execute
        end

        it "グラフのラベルが追加されていること" do
          expect(mr.lrange('graph-labels', 0, -1)).to match_array ["2014-01-31"]
        end

        it "グラフの値が追加されていること" do
          expect(mr.lrange('graph-values', 0, -1)).to match_array ["100"]
        end

        it "ポンペ数が初期化されていること" do
          expect(mr.get('ponpe-cnt')).to eq "1"
        end
      end

      context "グラフデータ格納最大数を超えている場合" do
        it "一番古いグラフデータが削除されていること" do
          mr.set('last-date','2014-01-31')
          mr.set('ponpe-cnt','100')
          365.times do | cnt | 
            mr.rpush('graph-labels', cnt)
            mr.rpush('graph-values', cnt)
          end

          Ponpetter::Scheduler.execute
          expect(mr.lpop('graph-labels')).to eq '1'
          expect(mr.lpop('graph-values')).to eq '1'
        end
      end
    end
  end
end

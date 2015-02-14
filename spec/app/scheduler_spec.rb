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

    # twitter
    twitter_client_mock = double('Twitter client')
    allow(twitter_client_mock).to receive(:run).and_return(tweets)
    allow(Ponpetter::TweetSearch).to receive(:new).and_return(twitter_client_mock)

  end

  describe "#execute" do
    before do
      Ponpetter::Scheduler.execute
    end

    it "前回処理日付に今日の日付が設定されていること" do
      expect(mr.get('last-date')).to eq "2015-02-01"
    end

    it "since_idが更新されていること" do
      expect(mr.get('since-id')).to eq "1234567890"
    end

    it "tweetが保存されていること" do
      expect(Marshal.load(mr.get('tweets'))).to eq tweets
    end

    it "ポンペ数が更新されていること" do
      expect(mr.get('ponpe-cnt')).to eq "1"
    end

    context "日替わり発生時" do
      before do
        mr.set('last-date','2014-01-31')
        mr.set('ponpe-cnt','100')
        Ponpetter::Scheduler.execute
      end

      it "グラフのラベルが追加されていること" do
        expect(mr.zrange('graph-labels', 0, 30)).to match_array ["2014-01-31"]
      end

      it "グラフの値が追加されていること" do
        expect(mr.zrange('graph-values', 0, 30)).to match_array ["100"]
      end

      it "ポンペ数が初期化されていること" do
        expect(mr.get('ponpe-cnt')).to eq "1"
      end

    end

  end
end

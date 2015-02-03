require File.dirname(__FILE__) + '/spec_helper'

describe "App" do
  include Rack::Test::Methods
  def app
    @app ||= Sinatra::Application
  end

  describe "GET /" do
    before :each do
      allow(Date).to receive(:today).and_return(Date.new(2015, 2, 1))

      mr = MockRedis.new
      mr.set('2015-02-01', 100)
      tweets = [
        {
          id: 1234567890,
          img: "http://pbs.twimg.com/profile_images/img/xxxxx.jpeg",
          autor: "hoge",
          text: "お腹痛い",
          time: "2015-02-01 16:57:17 +0900"
        }
      ]
      mr.set('tweets', Marshal.dump(tweets))

      allow(Ponpetter::Redis).to receive(:connect).and_return(mr)
    end

    subject do
      get '/'
      last_response
    end

    it 'ステータスコード200を返すこと' do
      expect(subject.status).to be 200
    end

    it '集計時点の日付が表示されていること' do
      expect(subject.body).to include '<p>2015-02-01</p>'
    end

    it 'ツイート合計数が表示されていること' do
      expect(subject.body).to include '<h2>只今のポンペ数 100人</h2>'
    end

    it 'ユーザーの画像が表示されていること' do
      expect(subject.body).to include '<img src="http://pbs.twimg.com/profile_images/img/xxxxx.jpeg">'
    end

    it 'ユーザー名が表示されていること' do
      expect(subject.body).to include '<a href="https://twitter.com/hoge" target="_blank">@hoge</a>'
    end

    it 'テキストが表示されていること' do
      expect(subject.body).to include 'お腹痛い'
    end

    it '時刻が表示されていること' do
      expect(subject.body).to include '<a href="https://twitter.com/hoge/status/1234567890" target="_blank">2015-02-01 16:57:17 +0900</a>'
    end

  end
end

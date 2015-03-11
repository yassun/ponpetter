require File.dirname(__FILE__) + '/spec_helper'

describe "App" do

  let(:set_up_mock_redis) {
    allow(Date).to receive(:today).and_return(Date.new(2015, 2, 1))
    mr = MockRedis.new
    mr.set('ponpe-cnt', 100)
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
    mr.rpush('graph-labels', "2015-01-31")
    mr.rpush('graph-values', 200)
    allow(Ponpetter::Redis).to receive(:connect).and_return(mr)
  }

  describe "GET /", js: true do
    include Capybara::DSL

    before :all do
      Capybara.app = Sinatra::Application.new
    end

    before :each do
      set_up_mock_redis
      visit '/'
    end

    subject { page }

    it { should have_title('Ponpetter') }

    it 'ステータスコードが200を返すこと' do
      expect(page.status_code).to eq(200)
    end

    it 'ツイート合計数が表示されていること' do
      within("div.counter") do
        should have_content('本日のポンペ数 100人')
      end
    end

    it 'ユーザーの画像が表示されていること' do
      within("div.tweets.row") do
        should have_selector("img[src$='http://pbs.twimg.com/profile_images/img/xxxxx.jpeg']")
      end
    end

    it 'ユーザー名が表示されていること' do
      within("div.tweets.row") do
        should have_link('@hoge', :href => 'https://twitter.com/hoge')
      end
    end

    it 'テキストが表示されていること' do
      within("div.tweets.row") do
        should have_content('お腹痛い')
      end
    end

    it '時刻が表示されていること' do
      within("div.tweets.row") do
        should have_link('2015-02-01 16:57:17 +0900', :href => 'https://twitter.com/hoge/status/1234567890')
      end
    end

  end

  describe 'GET /ponpe.json' do
    include Rack::Test::Methods
    def app
      @app ||= Sinatra::Application
    end

    before :each do
      set_up_mock_redis
    end

    subject do
      get '/ponpe.json'
      last_response
    end

    let(:json) {
      JSON.parse(subject.body)
    }

    it 'ステータスコードが200を返すこと' do
      expect(subject.status).to be 200
    end

    it 'ツイート合計数が返されていること' do
      expect(json['ponpe_cnt']).to eq "100"
    end

    it 'ツイートデータが返されていること' do
      expect(json['tweets']).to match([{
            "id"=>1234567890, "img"=>"http://pbs.twimg.com/profile_images/img/xxxxx.jpeg",
            "autor"=>"hoge", "text"=>"お腹痛い", "time"=>"2015-02-01 16:57:17 +0900"
          }])
    end

    it 'グラフデータが返されていること' do
      expect(json['graph']).to match({"labels"=>["2015-01-31"], "values"=>["200"]})
    end

  end
end

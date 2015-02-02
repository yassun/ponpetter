require File.dirname(__FILE__) + '/spec_helper'

describe "App" do
  include Rack::Test::Methods
  def app
    @app ||= Sinatra::Application
  end

  describe "GET /" do
    before :each do
      mr = MockRedis.new
      mr.set(Date.today.to_s, 100)
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
  end
end

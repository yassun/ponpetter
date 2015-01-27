require File.dirname(__FILE__) + '/spec_helper'

describe "App" do
  include Rack::Test::Methods
  def app
    @app ||= Sinatra::Application
  end

  describe "GET /" do
    before { get '/' }
    it "ステータスコード200が返ること" do
      expect(last_response.status).to be 200
    end
  end
end

require 'sinatra'
require 'sinatra/base'
require 'logger'
require 'unicorn'
require 'haml'
require 'sass'

class MainApp < Sinatra::Base

    # css
    get %r{^/(.*)\.css$} do
        scss :"style/#{params[:captures].first}"
    end

    # root
    get '/' do
        haml :index
    end

end


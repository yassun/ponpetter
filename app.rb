require 'sinatra'
require 'logger'
require 'unicorn'
require 'haml'
require 'sass'

# root
get '/' do
    haml :index
end

# css
get %r{^/(.*)\.css$} do
    scss :"style/#{params[:captures].first}"
end


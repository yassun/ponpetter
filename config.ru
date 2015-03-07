require File.join(File.dirname(__FILE__), 'app.rb')
require File.join(File.dirname(__FILE__), 'middlewares', 'backend.rb')

$stdout.sync = true

use Ponpetter::Backend
run Sinatra::Application


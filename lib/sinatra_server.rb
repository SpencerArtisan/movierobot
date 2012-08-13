require "sinatra"
require "net/http"
require "presenter"
require "fixnum"
require 'haml'
require 'json'

# Set-up stuff
STDOUT.sync = true
set :root, File.dirname(__FILE__) + "/../"
set :port, ARGV[0]
presenter = Presenter.new

get "/" do
  send_file "public/index.html"
end

get "/nice" do
  @films = JSON.parse presenter.get_films
  haml :films
end

get "/films" do
  presenter.get_films
end

get "/cache" do
  days = params[:days].to_i.days
  presenter.cache_films days
end

get "/favicon.ico" do
  ""
end


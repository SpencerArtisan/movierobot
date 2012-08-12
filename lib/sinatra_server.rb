require "sinatra"
require "net/http"
require "film_server"

# Set-up stuff
set :root, File.dirname(__FILE__) + "/../"
set :port, ARGV[0]
STDOUT.sync = true
film_server = FilmServer.new
puts "DB is " + ENV['SHARED_DATABASE_URL'].to_s

get "/" do
  send_file "public/index.html"
end

get "/films" do
  film_server.get_films
end

get "/cache" do
  film_server.cache_films params[:days]
end

get "/favicon.ico" do
  ""
end


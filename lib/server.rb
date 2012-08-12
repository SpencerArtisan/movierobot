require 'webrick'
require 'film_server'

class MyServlet < WEBrick::HTTPServlet::AbstractServlet
  @@instance = nil
  
  def initialize server, *options
    super
    puts "INITIALIZING MOVIE ROBOT SERVLET"
    @server = FilmServer.new
  end

  def self.get_instance server, *options
    @@instance = MyServlet.new server, *options if @@instance.nil?
    @@instance
  end

  def do_GET(request, response)
    puts 'Request received'
    response.status = 200
    response.content_type = "text/plain"
    @server.handleGET request, response
  end 
end

STDOUT.sync = true
puts "DB is " + ENV['SHARED_DATABASE_URL'].to_s

server = WEBrick::HTTPServer.new( :Port => ARGV[0] )
server.mount "/", MyServlet
trap("INT"){ server.shutdown }
server.start


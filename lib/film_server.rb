require 'db'
require 'showing'
require 'film_reviewer'
require 'television'
require 'presenter'
require 'fixnum'

class FilmServer
  def initialize presenter = Presenter.new
    @presenter = presenter
  end

  def handleGET request, response
    begin
      puts "Handling GET with request #{request}"
      response.body = get_response_body request, response
    rescue Exception => e
      puts "!!! ERROR OCCURRED #{e.message} #{e.backtrace}"
    end
  end 

  def get_response_body request, response
    if request.path == "/"
      response['Content-Type'] = 'text/html'
      IO.read "public/index.html"
    elsif request.path == "/cache"
      days = request.query['days']
      days = days.nil? ? 7 : days.to_i
      @presenter.build_cache days.days
    elsif request.path == "/films"
      @presenter.get_showings
    elsif request.path == "/db"
      Database.new.get
    else
      "Unexpected url.  Should be in the format [ip:port] or [ip:port]/films or [ip:port]/cache?days=x"
    end
  end

  def get_films
    puts "GET - films"
    @presenter.get_showings
  end

  def cache_films days = "2"
    puts "GET - cache #{days} days worth of films"
    @presenter.build_cache days.to_i.days
  end
end

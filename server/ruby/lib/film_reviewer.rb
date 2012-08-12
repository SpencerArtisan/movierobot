require 'rubygems'
require 'imdb'

class FilmReviewer
  def review showing
    puts "Requesting rating for #{showing.name}"
    candidates = Imdb::Search.new(showing.name).movies
    imdb_film = showing.best_match candidates
    puts "  Rating for #{showing.name} is #{imdb_film.rating} (stars #{imdb_film.cast_members[0..2]})"
    [imdb_film.rating, imdb_film.poster]
  end
end

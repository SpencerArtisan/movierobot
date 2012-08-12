require 'jsonifier'
require 'fixnum'
require 'amatch'
include Amatch

class Showing < Jsonifiable
  include Comparable

  attr_reader :name, :start_time, :end_time, :channel, :description, :genre, :certificate
  attr_accessor :rating, :image

  def initialize name, start_time, end_time, channel, description, genre, certificate, image_url = nil, rating = 0
    @name = name
    @start_time = start_time
    @end_time = end_time
    @channel = channel
    @description = description
    @genre = genre
    @certificate = certificate
    @image = image_url
    @rating = rating
  end

  def to_hash
    { :name => @name,
      :rating => @rating || 0,
      :channel => @channel,
      :start => @start_time.strftime('%Y-%m-%d %H:%M'),
      :end => @end_time.strftime('%Y-%m-%d %H:%M'),
      :description => @description,
      :genre => @genre,
      :certificate => @certificate,
      :image => @image }
  end

  def running_time_in_minutes
    (@end_time - @start_time) / 60
  end

  def self.match_title? actual_title, candidate_title
    candidate_title.upcase.start_with? actual_title.upcase
  end

  def best_match imdb_films
    best_match = nil
    best_match_score = -999
    imdb_films.each do |candidate| 
      score = match_score candidate

      if score > best_match_score
        best_match = candidate
        best_match_score = score
      end
    end

    puts "Best imdb match for #{@name} (#{@description}) was #{best_match.title} with #{best_match_score} match score"
    best_match
  end

  def match_score imdb_film
    matching_actors = imdb_film.cast_members.count {|actor| @description.include? actor}
    length_similarity = 1 / (1 + (imdb_film.length - running_time_in_minutes).abs)
    matching_actors + length_similarity
  end

  def ==(other)
    return false if other.nil?
    @name == other.name &&
      @rating ==  other.rating &&
      @channel == other.channel &&
      @end_time == other.end_time &&
      @start_time == other.start_time &&
      @description == other.description &&
      @genre == other.genre &&
      @certificate == other.certificate &&
      @image == other.image
  end
end

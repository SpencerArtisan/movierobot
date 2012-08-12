require 'store'
require 'television' 
require 'film_reviewer'

class Presenter
  TIMEOUT_FOR_IMDB_CALL_S = 120
  MAX_ATTEMPTS_TO_CALL_IMDB = 3

  def initialize television = Television.new, reviewer = FilmReviewer.new, store = Store.new
    @tv = television
    @reviewer = UnreliableObjectDelegate.new reviewer, TIMEOUT_FOR_IMDB_CALL_S, MAX_ATTEMPTS_TO_CALL_IMDB
    @store = store
    @review_threads = []
  end

  def build_cache cache_duration_in_seconds
    @store.reset
    end_time = Time.now + cache_duration_in_seconds
    @tv.reset end_time

    puts "BEGINNING TO CACHE showings up to #{end_time}"
    add_showings_to_cache
    @store.get_json
  end

  def add_showings_to_cache
    loop do
      add_from_channels
      break if @tv.all_showings_retrieved?
    end
    puts "CACHING COMPLETE" 
  end

  def add_from_channels
    next_batch = @tv.get_next
    remove_duplicates next_batch
    puts "Next batch of #{next_batch.count} showings being added"
    @store.add next_batch
    gather_ratings next_batch
  end

  def gather_ratings showings
    puts "Creating thread for reviewing #{showings.size} showings.  Now have #{@review_threads.size + 1} review threads."
    thread = Thread.new { review showings }
    @review_threads << thread
  end

  def review showings
    showings.each do |showing|
      rating, image = @reviewer.review showing
      showing.rating = rating
      showing.image = image
      puts "  Updated showing to #{showing}"
    end
    @review_threads.delete Thread.current
    puts "Finishing a reviewing thread.  Now have #{@review_threads.size} review threads."
    @store.persist if @reviewing_threads.empty?
  end

  def remove_duplicates next_batch
    next_batch.delete_if do |showing| 
      @store.contents.any? { |showing_in_cache| showing_in_cache.name == showing.name }
    end
  end

  def get_showings
    @store.get_json
  end
end

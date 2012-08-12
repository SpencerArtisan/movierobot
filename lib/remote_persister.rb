class RemotePersister
  @@key = "json"

  def initialize
    server = ENV['MEMCACHE_SERVERS'] || 'localhost:11211'
    user = ENV['MEMCACHE_USERNAME']
    password = ENV['MEMCACHE_PASSWORD']

    puts "Connecting to dalli server #{server}, username #{user}, password #{password}"
    @dalli_cache = Dalli::Client.new server
  end

  def reset
    puts "* RESETTING REMOTE CACHE"
    @dalli_cache.delete @@key
  end

  def save data
    puts "* SAVING DATA TO REMOTE CACHE: #{data}..."
    @dalli_cache.set @@key, data
    data
  end

  def retrieve
    data = @dalli_cache.get @@key
    puts "* RETRIEVING DATA FROM REMOTE CACHE #{data}"
    data
  end
end

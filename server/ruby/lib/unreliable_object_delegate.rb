require 'timeout'

class UnreliableObjectDelegate
  def initialize target, timeout_in_seconds, max_attempts
    @target = target
    @timeout_in_seconds = timeout_in_seconds
    @max_attempts = max_attempts
  end

  def method_missing method, *args, &block
    (@max_attempts - 1).times do
      begin
        return try_call method, *args, &block
      rescue
        puts "WARNING - call to #{method} timed out after #{@timeout_in_seconds}s.  Attempting another call..."
      end
    end
    
    puts "SEVERE WARNING - There have now been #{@max_attempts} timeouts on calls to #{method}.  Making final attempt..."
    return try_call method, *args, &block
  end

  def try_call method, *args, &block
    Timeout::timeout(@timeout_in_seconds) do
      result = @target.send method, *args, &block
      puts "Unreliable method #{method} succeeded.  Result is #{result.to_s[0..60]}..."
      result
    end
  end
end

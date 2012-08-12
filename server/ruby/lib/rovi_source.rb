require 'soap_source'
require 'soap_converter'
require 'unreliable_object_delegate'
require 'fixnum'
require 'hpricot'
require 'showing'
require 'showing_batch'
require 'channel_source'

class RoviSource
  TIMEOUT_FOR_ROVI_CALL_S = 20
  MAX_ATTEMPTS_TO_CALL_ROVI = 4
  SCHEDULE_REQUEST_DURATION_S = 4.hours
  MINIMUM_FILM_LENGTH_M = 70

  def initialize soap_source = SoapSource.new, channels = ChannelSource.new
    @channels = channels
    @soap_source = UnreliableObjectDelegate.new soap_source, TIMEOUT_FOR_ROVI_CALL_S, MAX_ATTEMPTS_TO_CALL_ROVI
  end

  def get_showings start_time
    puts "Requesting showings starting at #{start_time}"
    soap = @soap_source.read start_time, @channels
    return empty_batch(start_time) if soap.nil? || soap.empty? || has_no_programmes(soap)

    showings = extract_showings soap
    batch start_time, showings
  end

  def empty_batch start_time
    batch start_time, []
  end

  def batch start_time, showings
    ShowingBatch.new showings, start_time + SCHEDULE_REQUEST_DURATION_S
  end

  def has_no_programmes soap
    !soap.include? "ListingsAiring"
  end

  def extract_showings soap
    doc = Hpricot.XML soap
    
    showings = (doc/"ListingsAiring")
    showings.delete_if {|showing| (showing/'Category').inner_html != 'Movie' || (showing/'Duration').inner_html.to_i < MINIMUM_FILM_LENGTH_M }
    showings = showings.map {|showing| SoapConverter.new.convert showing, channel(showing)}
    
    puts "Showings in soap: #{showings.size}"
    showings
  end

  def channel showing
    showing_channel_code = (showing/'SourceId').inner_html
    @channels.find {|channel| channel.code.to_s == showing_channel_code}.name
  end
end

class DummySoapSource
  def read x
    File.read('rovi/get_grid_schedule_response.xml') 
  end
end

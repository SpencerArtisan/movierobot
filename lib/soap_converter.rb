require 'showing'
require 'hpricot'
require 'time'
require 'fixnum'

class SoapConverter
  def convert xml, channel
    Showing.new extract(xml, 'Title'), 
                start_time(xml), 
                end_time(xml), 
                channel,
                extract(xml, 'Copy'),
                extract(xml, 'Subcategory'),
                extract(xml, 'MovieRating')
  end

  def start_time xml
    Time.parse(extract(xml, 'AiringTime'))
  end

  def end_time xml
    start_time(xml) + extract(xml, 'Duration').to_i.minutes
  end

  def extract xml, node
    (xml/node).inner_html
  end
end

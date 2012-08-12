require 'soap_source'
require 'fixnum'
require 'channel'

describe SoapSource do
  it 'should retrieve some xml from the rovi service' do
    film4 = Channel.new 'Film 4', 25409
    bbc1 = Channel.new 'BBC 1', 24872
    xml = SoapSource.new.read Time.now, [film4, bbc1]
    puts xml
    xml.should include('ListingsAiring')
  end
end

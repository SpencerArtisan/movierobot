require 'soap_converter'
require 'hpricot'

describe SoapConverter do
  it 'should convert a soap showing into a showing' do
    soap = File.read('rovi/showing.xml') 
    showing_xml = (Hpricot.XML(soap)/"ListingsAiring")[0]

    showing = SoapConverter.new.convert showing_xml, 'Film4'
    showing.name.should == 'Day Watch'
    showing.start_time.should == Time.utc(2012, 8, 12, 0, 15, 0)
    showing.end_time.should == Time.utc(2012, 8, 12, 2, 50, 0)
    showing.channel.should == 'Film4'
    showing.description.should == 'An ancient war between light and darkness continues in Moscow. Konstantin Khabensky, Maria Poroshina, Dima Martynov.'
    showing.genre.should == 'horror'
    showing.certificate.should == 'R'
    showing.image = 'some url'
  end
end

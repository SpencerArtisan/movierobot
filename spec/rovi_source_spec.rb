require 'showing'
require 'rovi_source'
require 'timecop'
require 'channel'

describe 'RoviSource' do
  let (:channels) { [Channel.new('Film 4', 25409), Channel.new('BBC 1', 24872)]}
  let (:soap_source) { stub }
  let (:source) { RoviSource.new soap_source, channels }

  before do
    Timecop.freeze
  end

  it 'should pass the channel through to the soap source' do
    soap_source.should_receive(:read).with Time.now, channels
    source.get_showings Time.now
  end
  
  it 'should return no showings from a nil soap packet' do
    soap_source.stub(:read).with(Time.now, channels).and_return nil
    source.get_showings(Time.now).end_date.should == Time.now + 4.hours
  end

  it 'should return no showings from an empty soap packet' do
    soap_source.stub(:read).with(Time.now, channels).and_return ''
    source.get_showings(Time.now).end_date.should == Time.now + 4.hours
  end

  it 'should return no showings if there were no programmes in the soap packet' do
    soap_source.stub(:read).with(Time.now, channels).and_return 'wibble'
    source.get_showings(Time.now).end_date.should == Time.now + 4.hours
  end

  it 'should extract a showing from a soap response' do
    soap_response = File.read 'rovi/get_linear_schedule_response.xml'
    soap_source.stub(:read).with(Time.now, channels).and_return soap_response
    showings = source.get_showings(Time.now).showings
    showings.should have(2).items
    showings[0].should ==
          Showing.new('Day Watch', 
            Time.utc(2012, 8, 12, 0, 15, 0),
            Time.utc(2012, 8, 12, 2, 50, 0),
            'Film 4',
            'An ancient war between light and darkness continues in Moscow. Konstantin Khabensky, Maria Poroshina, Dima Martynov.',
            'horror',
            'R')
    showings[1].should ==
          Showing.new('Final Destination 3', 
            Time.utc(2012, 8, 11, 22, 30, 0),
            Time.utc(2012, 8, 12, 0, 15, 0),
            'Film 4',
            'The Grim Reaper pursues a teen and her friends. Mary Elizabeth Winstead.',
            'horror',
            'R')
  end

  it 'should return the end date 4 hours after the start reqest time' do
    soap_response = File.read 'rovi/get_linear_schedule_response.xml'
    soap_source.stub(:read).with(Time.now, channels).and_return soap_response
    source.get_showings(Time.now).end_date.should == Time.now + 4.hours
  end 

  it 'should return a end date 4 hours after the start request time when there are no showings' do
    soap_response = File.read 'rovi/get_linear_schedule_response_no_films.xml'
    soap_source.stub(:read).with(Time.now, channels).and_return soap_response
    source.get_showings(Time.now).end_date.should == Time.now + 4.hours
  end

  it 'should filter out short showings which are incorrectly marked as films' do
    soap_response = File.read 'rovi/get_linear_schedule_response_fake_film.xml'
    soap_source.stub(:read).with(Time.now, channels).and_return soap_response 
    source.get_showings(Time.now).showings.should have(0).items
  end
  
  it 'should integrate with the channel source' do
    soap_source.stub(:read).and_return nil
    rovi = RoviSource.new soap_source
    rovi.get_showings Time.now
  end
end


require 'showing'
require 'spec_helper'

describe Showing do
  let(:showing) { build :showing }

  it 'should convert a showing to a json string' do
    showing = Showing.new 'The Godfather', 
      Time.new(2010, 4, 11, 23, 45, 0),
      Time.new(2010, 4, 12, 1, 15, 0),
      'ITV',
      'Mafia film',
      'gangster',
      'R',
      'imageurl',
      9.2

    showing.to_json.should == '{"name":"The Godfather","rating":9.2,"channel":"ITV","start":"2010-04-11 23:45","end":"2010-04-12 01:15","description":"Mafia film","genre":"gangster","certificate":"R","image":"imageurl"}'
  end

  it 'should represent nil ratings as zero in the json string' do
    showing = build :showing, :rating => nil
    showing.to_json.should include '"rating":0'
  end

  it 'should be able to tell you the running time of a film' do
    Timecop.freeze
    showing = build :showing, :name => 'The Ladykillers', :start_time => Time.now, :end_time => Time.now + 105.minutes
    showing.running_time_in_minutes.should == 105
  end

  context 'matching' do
    it 'should consider an imdb film a good match if imdb actors feature in the showing description' do
      showing = build :showing, :name => 'The Ladykillers', :description => 'Comedy with Alec Guiness'
      imdb_film_with_matching_actors = build :imdb_film, :title => 'The Ladykillers', :cast_members => ['Alec Guiness']
      imdb_film_without_matching_actors = build :imdb_film, :title => 'The Ladykillers', :cast_members => ['Tom Hanks']
      match = showing.best_match [imdb_film_without_matching_actors, imdb_film_with_matching_actors]
      match.should == imdb_film_with_matching_actors
    end

    it 'should try to match on film length if no actors are available' do
      Timecop.freeze
      showing = build :showing, :name => 'The Ladykillers', :start_time => Time.now, :end_time => Time.now + 105.minutes
      imdb_film_with_similar_length = build :imdb_film, :length => 90
      imdb_film_with_dissimilar_length = build :imdb_film, :length => 150
      match = showing.best_match [imdb_film_with_dissimilar_length, imdb_film_with_similar_length]
      match.should == imdb_film_with_similar_length
    end

    it 'should falls back on the first imdb film being the best match in the absence of more information' do
      imdb_film1 = build :imdb_film, :title => 'The Drum'
      imdb_film2 = build :imdb_film, :title => 'Tin Drum'
      match = showing.best_match [imdb_film1, imdb_film2]
      match.should == imdb_film1
    end
  end

  context 'equality' do
    it 'should recognise two identical showings as equal' do
      identical_showing = build :showing
      showing.should == identical_showing
    end

    it 'should recognise showings on different channels as unequal' do
      different_showing = build :showing, :channel => 'different'
      showing.should_not == different_showing
    end

    it 'should recognise two differently rated showings as unequal' do
      different_showing = build :showing, :rating => 3.5
      showing.should_not == different_showing
    end

    it 'should recognise two differently named showings as unequal' do
      different_showing = build :showing, :name => 'different'
      showing.should_not == different_showing
    end

    it 'should recognise showings with different end times unequal' do
      different_showing = build :showing, :end_time => Time.now
      showing.should_not == different_showing
    end

    it 'should recognise showings with different start times unequal' do
      different_showing = build :showing, :start_time => Time.now
      showing.should_not == different_showing
    end

    it 'should recognise showings with different images as unequal' do
      different_showing = build :showing, :image_url => 'different'
      showing.should_not == different_showing
    end

    it 'should recognise showings with different descriptions as unequal' do
      different_showing = build :showing, :description => 'different'
      showing.should_not == different_showing
    end

    it 'should recognise showings with different genres as unequal' do
      different_showing = build :showing, :genre => 'different'
      showing.should_not == different_showing
    end

    it 'should recognise showings with different certificates as unequal' do
      different_showing = build :showing, :certificate => 'different'
      showing.should_not == different_showing
    end
  end
end

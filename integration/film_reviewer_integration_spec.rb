require 'film_reviewer'
require 'showing'
require 'spec_helper'

describe FilmReviewer do
  let (:reviewer) { FilmReviewer.new }

  it 'should not confuse The Drum with Tin Drum' do
    assert_rating 'The Drum', 6.6
  end

  it 'should not confuse Infamous with The Childrens Hour' do
    assert_rating 'Infamous', 7.0
  end

  it 'should not confuse The Tall Men with All The Presidents Men' do
    assert_rating 'The Tall Men', 6.7
  end

  it 'should return a rating for a known unqiue film name' do
    assert_rating 'The Godfather', 9.2
  end

  it 'should handle sequels' do
    assert_rating 'Night at the museum 2', 5.9
  end

  def assert_rating film_name, expected_rating
    showing = build :showing, :name => film_name
    reviewer.review(showing)[0].should == expected_rating
  end
end

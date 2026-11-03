require_relative '../../../../test_helper'

class RioUk::Internal::Parser::EventTest < Minitest::Test
  include FixturesHelper

  DATES = (FIXTURE_DAY..FIXTURE_DAY + 365)

  def test_films_have_a_director_or_a_year
    assert event('Year' => '', 'Director' => 'Alain Gomis').film?
    assert event('Year' => '1965', 'Director' => '').film?
    refute event('Year' => '', 'Director' => ' ').film?
  end

  def test_live_events_are_not_films
    refute event('TypeDescription' => 'Live Music').film?
    assert event('TypeDescription' => 'Main Feature').film?
  end

  def test_gigs_and_parties_in_the_fixture_are_not_films
    titles = fixture_events.reject { |data| RioUk::Internal::Parser::Event.new(data).film? }.map { |data| data['Title'] }

    assert_equal ['Something Wicked This Way Comes: a folk + cosmic horror rave', 'Velcro Flats presents POZI'], titles.sort
  end

  def test_performances_keep_to_the_dates
    performances = event.performances(Date.new(2026, 11, 2)..Date.new(2026, 11, 2))

    assert_equal [Time.utc(2026, 11, 2, 18, 30)], performances.map { |p| p[:starting_at] }
  end

  def test_times_are_london_time
    performance = event('Performances' => [savoy_performance('StartDate' => '2027-06-01', 'StartTime' => '1830')])
                  .performances(Date.new(2027, 6, 1)..Date.new(2027, 6, 1)).first

    assert_equal Time.utc(2027, 6, 1, 17, 30), performance[:starting_at]
  end

  def test_booking_urls_are_absolute
    assert_equal 'https://riocinema.org.uk/Rio.dll/Booking?Booking=TSelectItems.waSelectItemsPrompt.TcsPerformance_1',
                 attributes[:booking_url]
  end

  def test_sold_out_and_closed_performances_have_no_booking_url
    assert_nil attributes('IsSoldOut' => 'Y')[:booking_url]
    assert_nil attributes('IsOpenForSale' => false)[:booking_url]
  end

  def test_flags_are_variants
    assert_equal %w(baby), attributes('CB' => 'Y')[:variant]
    assert_equal %w(senior), attributes('CM' => 'Y')[:variant]
    assert_equal %w(kids), attributes('FF' => 'Y', 'HC' => 'Y')[:variant]
    assert_equal %w(subtitled), attributes('HoH' => 'Y')[:variant]
    assert_equal %w(q&a), attributes('QA' => 'Y')[:variant]
    assert_equal %w(relaxed), attributes('RS' => 'Y')[:variant]
    assert_equal [], attributes('PP' => 'Y', 'RF' => 'Y', 'SP' => 'Y', 'NoAds' => 'Y')[:variant]
  end

  def test_titles_name_variants
    assert_equal %w(35mm), attributes_for_title('Little White Lies: PAN&#39;S LABYRINTH on 35mm')[:variant]
    assert_equal %w(q&a), attributes_for_title('WE, THE HATED + Q&amp;A')[:variant]
    assert_equal %w(sing_along), attributes_for_title('MAMMA MIA! Sing-a-long')[:variant]
  end

  def test_dimension
    assert_equal '2d', attributes[:dimension]
    assert_equal '3d', event('Tags' => [{ 'Format' => '3D' }]).performances(DATES).first[:dimension]
  end

  def test_film_year_from_the_listing
    assert_equal 2026, attributes[:film_year]
    assert_nil event('Year' => '1974 / 1976').performances(DATES).first[:film_year]
    assert_nil event('Year' => 'Various').performances(DATES).first[:film_year]
    assert_equal 1999, event('Year' => '', 'Title' => 'THE MUMMY (1999)').performances(DATES).first[:film_year]
  end

  def test_film_name_uses_strands_and_director
    pink_palace = event('Title' => 'Pink Palace: The Einstein of Sex', 'Seasons' => [{ 'SeasonName' => 'Pink Palace' }])
    director = event('Title' => "Black History Month:  Alain Gomis' DAO ", 'Director' => 'Alain Gomis')

    assert_equal 'The Einstein of Sex', pink_palace.performances(DATES).first[:film_name]
    assert_equal 'Dao', director.performances(DATES).first[:film_name]
  end

  def test_unescapes_strands
    carers = event('Title' => 'Carers &amp; Babies: I LOVE BOOSTERS', 'Seasons' => [{ 'SeasonName' => 'Carers &amp; Babies' }])

    assert_equal 'I Love Boosters', carers.performances(DATES).first[:film_name]
  end

  def test_performances_read_labels_and_series_from_the_title
    relaxed = performance_for_title('Relaxed Screening: FATHERLAND')
    hamlet = performance_for_title('NT Live: HAMLET')

    assert_equal 'Fatherland', relaxed.film_name
    assert_equal %w(relaxed), relaxed.variant
    assert_equal 'Hamlet', hamlet.film_name
    assert_equal 'National Theatre Live', hamlet.event.name
  end

  def test_no_festival
    assert_nil attributes[:festival]
  end

  private

  def attributes(changes = {})
    event('Performances' => [savoy_performance(changes)]).performances(DATES).first
  end

  def attributes_for_title(title)
    event('Title' => title).performances(DATES).first
  end

  def performance_for_title(title)
    RioUk::Performance.new(attributes_for_title(title).merge(cinema_id: 'rio', cinema_name: 'Rio Cinema'))
  end

  def event(changes = {})
    data = {
      'ID' => 1, 'Title' => 'FATHERLAND', 'TypeDescription' => 'Film', 'Director' => 'Someone', 'Year' => '2026',
      'Seasons' => [], 'Tags' => [{ 'Format' => '' }],
      'Performances' => [savoy_performance('StartDate' => '2026-11-02', 'StartTime' => '1830')]
    }
    RioUk::Internal::Parser::Event.new(data.merge(changes))
  end

  def savoy_performance(changes = {})
    {
      'ID' => 1, 'IsSoldOut' => 'N', 'StartDate' => '2026-11-01', 'StartTime' => '2045', 'IsOpenForSale' => true,
      'URL' => 'Booking?Booking=TSelectItems.waSelectItemsPrompt.TcsPerformance_1'
    }.merge(changes)
  end
end

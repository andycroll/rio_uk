require_relative '../../test_helper'

class RioUk::PerformanceTest < Minitest::Test
  include WebsiteStubs

  BOOKING = 'https://riocinema.org.uk/Rio.dll/Booking?Booking=TSelectItems.waSelectItemsPrompt.'.freeze

  def setup
    stub_whats_on
  end

  def test_at_returns_films_in_time_order
    performances = performances_at('rio')

    assert(performances.all? { |p| p.instance_of?(RioUk::Performance) })
    assert_equal 23, performances.count
    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_reads_every_date_from_one_request
    performances = performances_at('Rio')

    assert_equal Date.new(2027, 1, 25), performances.last.showing_on
    assert_requested :get, WHATS_ON, times: 1
  end

  def test_at_keeps_to_the_range
    assert_equal 4, at(from: Date.new(2026, 11, 2), to: Date.new(2026, 11, 2)).count
  end

  def test_at_defaults_to_two_weeks_from_today
    performances = TZInfo::Timezone.get('Europe/London').stub(:now, Time.utc(2026, 11, 1, 12)) do
      RioUk::Performance.at('rio')
    end

    assert_equal 13, performances.count
    assert_operator performances.last.showing_on, :<=, FIXTURE_DAY + 13
  end

  def test_at_sets_cinema_details
    performances = performances_at('rio')

    assert_equal ['rio'], performances.map(&:cinema_id).uniq
    assert_equal ['Rio Cinema'], performances.map(&:cinema_name).uniq
  end

  def test_at_parses_first_performance
    performance = performances_at('rio').first

    assert_equal 'Dao', performance.film_name
    assert_nil performance.film_year
    assert_equal Time.utc(2026, 11, 1, 13, 30), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_equal %w(q&a), performance.variant
    assert_nil performance.festival
    assert_equal "#{BOOKING}TcsWebMenuItem_0.TcsWebTab_0.TcsPerformance_2884892.TcsSection_1299", performance.booking_url
  end

  def test_variants
    assert_equal %w(baby), find('I Love Boosters', Time.utc(2026, 11, 2, 11)).variant
    assert_equal %w(subtitled), find('I Love Boosters', Time.utc(2026, 11, 2, 18)).variant
    assert_equal %w(senior), find('The Lunchbox').variant
    assert_equal %w(35mm), find("Pan's Labyrinth").variant
  end

  def test_sold_out_performances_have_no_booking_url
    sold_out, on_sale = performances_at('rio').select { |p| p.film_name == 'You Can See Everything' }.partition { |p| p.booking_url.nil? }

    assert_equal 1, sold_out.size
    assert_equal 1, on_sale.size
  end

  def test_partner_booking_urls
    assert_equal 'https://japanesefilm.club/your-name-rio-cinema-dalston-2026-11-14-1400', find('Your Name').booking_url
  end

  def test_gigs_and_parties_are_dropped
    names = performances_at('rio').map(&:film_name)

    refute_includes names, 'Pozi'
    refute(names.any? { |name| name.include?('Something Wicked') })
  end

  def test_unknown_cinema_has_no_performances
    assert_empty performances_at('zzz')
    assert_not_requested :get, WHATS_ON
  end

  def test_at_rejects_range_ending_before_start
    assert_raises(ArgumentError) { at(from: FIXTURE_DAY, to: FIXTURE_DAY - 1) }
  end

  def test_new_sets_defaults
    performance = RioUk::Performance.new(
      film_name: 'Daisies', cinema_id: 'rio', cinema_name: 'Rio Cinema', starting_at: Time.utc(2026, 11, 23, 18, 30)
    )

    assert_nil performance.booking_url
    assert_equal '2d', performance.dimension
    assert_nil performance.festival
    assert_nil performance.film_year
    refute performance.subtitled?
    assert_equal [], performance.variant
  end

  private

  def at(from:, to:)
    RioUk::Performance.at('rio', from: from, to: to)
  end

  def performances_at(cinema_id)
    RioUk::Performance.at(cinema_id, from: FIXTURE_DAY, to: FIXTURE_DAY + 365)
  end

  def find(film_name, starting_at = nil)
    performances_at('rio').find { |p| p.film_name == film_name && (starting_at.nil? || p.starting_at == starting_at) }
  end
end

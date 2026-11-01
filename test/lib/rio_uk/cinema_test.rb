require_relative '../../test_helper'

class RioUk::CinemaTest < Minitest::Test
  def test_all_returns_the_one_cinema_without_requests
    cinemas = RioUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(RioUk::Cinema) })
    assert_equal %w(rio), cinemas.map(&:id)
  end

  def test_new_stores_downcase_string_id
    assert_equal 'rio', RioUk::Cinema.new('Rio').id
  end

  def test_name_full_name_and_slug
    cinema = RioUk::Cinema.new('rio')

    assert_equal 'Rio Cinema', cinema.name
    assert_equal 'Independent Rio Cinema', cinema.full_name
    assert_equal 'independent-rio-cinema', cinema.slug
  end

  def test_brand
    assert_equal 'Independent', RioUk::Cinema.new('rio').brand
  end

  def test_url
    assert_equal 'https://riocinema.org.uk', RioUk::Cinema.new('rio').url
  end

  def test_adr
    expected = {
      street_address:   '107 Kingsland High Street',
      extended_address: nil,
      locality:         'London',
      region:           nil,
      postal_code:      'E8 2PB',
      country_name:     'United Kingdom'
    }

    assert_equal expected, RioUk::Cinema.new('rio').adr
  end

  def test_coordinates
    cinema = RioUk::Cinema.new('rio')

    assert_in_delta 51.5496199, cinema.latitude
    assert_in_delta(-0.0755805, cinema.longitude)
  end

  def test_unknown_cinema_has_no_details
    cinema = RioUk::Cinema.new('zzz')

    assert_equal '', cinema.name
    assert_equal '', cinema.url
    assert_nil cinema.latitude
    assert_nil cinema.longitude
  end
end

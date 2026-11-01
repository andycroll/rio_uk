require_relative 'live_helper'

# The what's on page: one request.
class LiveIntegrationTest < Minitest::Test
  include LiveHelper

  def test_the_cinema_has_performances_weeks_ahead
    today = Date.today
    performances = RioUk::Performance.at('rio', from: today, to: today + 365)

    assert(performances.all? { |p| p.instance_of?(RioUk::Performance) })
    assert_operator performances.count, :>, 20
    assert_operator performances.map(&:showing_on).max, :>, today + 21
    assert(performances.filter_map(&:booking_url).all? { |url| url.start_with?('https://') })
  end
end

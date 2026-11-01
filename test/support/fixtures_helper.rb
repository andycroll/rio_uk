# Read fixtures from disk: the what's on page from 1 November 2026, trimmed
# to its programme of a few events with a few performances each and short
# synopses. It follows the shape in api_shapes.rb.
module FixturesHelper
  FIXTURE_DAY = Date.new(2026, 11, 1)

  private

  def whats_on_html
    read_fixture('website/whats-on.html')
  end

  def fixture_events
    JSON.parse(whats_on_html[RioUk::Internal::Website::EVENTS, 1]).fetch('Events')
  end

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end

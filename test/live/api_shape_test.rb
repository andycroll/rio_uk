require_relative 'live_helper'

# The what's on page: one request.
class LiveApiShapeTest < Minitest::Test
  include ApiShapes
  include LiveHelper

  def test_whats_on_is_readable
    assert_events_shape(RioUk::Internal::Website.new.events)
  end
end

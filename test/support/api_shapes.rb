# The parts of the what's on page's Savoy programme the gem reads. Checked
# against the trimmed fixture and, in the live suite, against the real page
# held only in memory.
module ApiShapes
  # Savoy's own booking page, or a partner's for some special events
  BOOKING_PATH = /\A(?:Booking\?Booking=TSelectItems\.waSelectItemsPrompt\.\S*TcsPerformance_\d+\S*|https:\/\/\S+)\z/
  FLAG = /\A[YN]\z/

  private

  def assert_events_shape(events)
    refute_empty events
    events.each { |event| assert_event_shape(event) }
  end

  def assert_event_shape(event)
    assert_kind_of Integer, event.fetch('ID')
    refute_empty event.fetch('Title').strip
    assert_kind_of String, event.fetch('TypeDescription')
    assert_kind_of String, event.fetch('Director')
    assert_kind_of String, event.fetch('Year')
    event.fetch('Seasons').each { |season| assert_kind_of String, season.fetch('SeasonName') }
    event.fetch('Tags').each { |tag| assert_kind_of String, tag.fetch('Format') }
    event.fetch('Performances').each { |performance| assert_performance_shape(performance) }
  end

  def assert_performance_shape(performance)
    Date.iso8601(performance.fetch('StartDate'))
    assert_match(/\A([01]\d|2[0-3])[0-5]\d\z/, performance.fetch('StartTime'))
    assert_match FLAG, performance.fetch('IsSoldOut')
    RioUk::Internal::Parser::Event::FLAGS.each_key { |flag| assert_match FLAG, performance.fetch(flag) }
    assert_includes [true, false], performance.fetch('IsOpenForSale')
    assert_match BOOKING_PATH, performance.fetch('URL')
  end
end

require_relative '../../../test_helper'

class RioUk::Internal::WebsiteTest < Minitest::Test
  include WebsiteStubs

  def test_events_reads_the_programme_from_the_page
    stub_whats_on
    events = RioUk::Internal::Website.new.events

    assert_equal 20, events.size
    assert_includes events.map { |event| event['Title'] }, 'FATHERLAND'
  end

  def test_events_are_empty_without_a_programme
    stub_request(:get, WHATS_ON).to_return(status: 200, body: '<html></html>')

    assert_empty RioUk::Internal::Website.new.events
  end

  def test_url_resolves_savoy_links
    assert_equal 'https://riocinema.org.uk/Rio.dll/Booking?Booking=TSelectItems.waSelectItemsPrompt.TcsPerformance_1',
                 RioUk::Internal::Website.url('Booking?Booking=TSelectItems.waSelectItemsPrompt.TcsPerformance_1')
    assert_equal 'https://gel.now/events/1207', RioUk::Internal::Website.url('https://gel.now/events/1207')
  end

  def test_errors_name_the_status_but_not_the_body
    stub_request(:get, WHATS_ON).to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { RioUk::Internal::Website.new.events }
    assert_equal 'HTTP error 500 from riocinema.org.uk', error.message
  end

  def test_transient_errors_are_retried
    stub_request(:get, WHATS_ON).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: whats_on_html)

    Cinebase::Http.stub(:pause, nil) { RioUk::Internal::Website.new.events }

    assert_requested :get, WHATS_ON, times: 2
  end
end

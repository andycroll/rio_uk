require_relative 'fixtures_helper'

# Serve the fixture in place of the Rio Cinema website
module WebsiteStubs
  include FixturesHelper

  WHATS_ON = 'https://riocinema.org.uk/Rio.dll/WhatsOn'.freeze

  private

  def stub_whats_on
    stub_request(:get, WHATS_ON).to_return(status: 200, body: whats_on_html)
  end
end

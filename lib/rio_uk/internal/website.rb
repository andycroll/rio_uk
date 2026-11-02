# frozen_string_literal: true

module RioUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads the Rio Cinema's website, run on Savoy Systems' ticketing. No
    # token is needed.
    class Website
      WHATS_ON = 'https://riocinema.org.uk/Rio.dll/WhatsOn'
      # Savoy pages carry the whole programme as one line of JSON
      EVENTS = /^var Events =\s*(\{.*\})\s*$/

      def initialize
        @http = Cinebase::Http.new
      end

      # Every event on sale with every advertised performance, however far
      # ahead, including sold out ones
      # @return [Array<Hash>] Savoy events, each with its 'Performances'
      def events
        JSON.parse(@http.get(WHATS_ON)[EVENTS, 1] || '{}').fetch('Events', [])
      end

      # @param [String] path a Savoy link relative to the what's on page,
      #   e.g. 'Booking?Booking=...'
      # @return [String] the absolute url
      def self.url(path)
        URI.join(WHATS_ON, path).to_s
      end
    end
  end
end

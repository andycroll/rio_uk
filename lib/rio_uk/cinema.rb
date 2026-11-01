module RioUk
  # The object representing the Rio Cinema in Dalston, London
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the cinema's id, 'rio'

    # The Rio is one venue. Its id is the name of its Savoy site, as in
    # riocinema.org.uk/Rio.dll.
    VENUES = {
      'rio' => {
        name: 'Rio Cinema', street_address: '107 Kingsland High Street', locality: 'London',
        postal_code: 'E8 2PB', latitude: 51.5496199, longitude: -0.0755805
      }
    }.freeze

    ADDRESS_PARTS = %i(street_address extended_address locality region postal_code).freeze
    URL = 'https://riocinema.org.uk'.freeze

    # Constructor
    # @param [String] id the cinema's id, 'rio' or 'Rio'
    # @return [RioUk::Cinema]
    def initialize(id)
      @id = id.to_s.downcase
    end

    # Return basic cinema information for all cinemas
    # @return [Array<RioUk::Cinema>] the one cinema
    # @example
    #   RioUk::Cinema.all
    #   #=> [<RioUk::Cinema>]
    def self.all
      VENUES.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = RioUk::Cinema.new('rio')
    #   cinema.adr
    #   #=> {
    #         street_address:   '107 Kingsland High Street',
    #         extended_address: nil,
    #         locality:         'London',
    #         region:           nil,
    #         postal_code:      'E8 2PB',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      ADDRESS_PARTS.to_h { |part| [part, venue[part]] }.merge(country_name: 'United Kingdom')
    end

    # Brand of the cinema
    # @return [String] which will always be 'Independent'
    def brand
      'Independent'.freeze
    end

    # @return [Float, nil]
    def latitude
      venue[:latitude]
    end

    # @return [Float, nil]
    def longitude
      venue[:longitude]
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   RioUk::Cinema.new('rio').name
    #   #=> 'Rio Cinema'
    def name
      venue[:name].to_s
    end

    # The url of the cinema's website
    # @return [String]
    # @example
    #   RioUk::Cinema.new('rio').url
    #   #=> 'https://riocinema.org.uk'
    def url
      venue.empty? ? '' : URL
    end

    private

    def venue
      VENUES.fetch(id, {})
    end
  end
end

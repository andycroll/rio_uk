# frozen_string_literal: true

module RioUk
  # @api private
  module Internal
    module Parser
      # Reads one Savoy event, a film or other listing with its performances
      class Event
        # TypeDescription of films, e.g. 'Film' or 'Main Feature'. Other
        # types are live events.
        FILM_TYPE = /\b(?:film|feature)s?\b/i

        # The Rio's performance flags and the variants they mean. PP (Pink
        # Palace), RF (Rio Forever), SP (special event) and NoAds are strands
        # and promises, not variants.
        FLAGS = {
          'CB' => 'baby',      # Carers + Baby
          'CM' => 'senior',    # Classic Matinee, for the over 60s
          'FF' => 'kids',      # Family Flicks
          'HC' => 'kids',      # Hackney Children's Film Fest
          'HoH' => 'subtitled', # Hard of Hearing
          'QA' => 'q&a',
          'RS' => 'relaxed'
        }.freeze

        TITLE_VARIANTS = {
          /\b35mm\b/i => '35mm',
          /\b70mm\b/i => '70mm',
          /\bQ\s?[&+]\s?A\b/i => 'q&a',
          /\bSing[- ]?A[- ]?Long\b/i => 'sing_along'
        }.freeze

        YES = 'Y'
        THREE_D = /\b3D\b/i
        YEAR = /\A\d{4}\z/

        # @param [Hash] event one of the website's Savoy events
        def initialize(event)
          @event = event
        end

        # Films have a director or a year. Gigs and parties listed as films
        # have neither.
        # @return [Boolean]
        def film?
          @event['TypeDescription'].to_s.match?(FILM_TYPE) && !(director.empty? && year_field.empty?)
        end

        # @param [Range<Date>] dates listings dates to keep
        # @return [Array<Hash>] options for RioUk::Performance.new
        def performances(dates)
          @event.fetch('Performances', []).filter_map do |performance|
            date = Date.iso8601(performance.fetch('StartDate'))
            attributes(performance, date) if dates.cover?(date)
          end
        end

        private

        def attributes(performance, date)
          starting_at = starting_at(performance, date)
          {
            booking_url: booking_url(performance),
            dimension: [title, format].any? { |text| text.match?(THREE_D) } ? '3d' : '2d',
            festival: Cinebase::Festival.from_title(title, year: starting_at.year),
            film_name: film_name,
            film_year: film_year,
            starting_at: starting_at,
            variant: variant(performance)
          }
        end

        def booking_url(performance)
          if performance['IsSoldOut'] == YES || !performance['IsOpenForSale']
            nil
          else
            Website.url(performance.fetch('URL'))
          end
        end

        def director
          @event['Director'].to_s.strip
        end

        def film_name
          @film_name ||= TitleSanitizer.new(title, director: director, strands: strands).sanitized
        end

        # Double bills give two years, e.g. '1974 / 1976', and programmes of
        # shorts 'Various'
        def film_year
          year_field.match?(YEAR) ? year_field.to_i : Cinebase::TitleSanitizer.film_year(title)
        end

        def format
          @event.fetch('Tags', []).map { |tag| tag['Format'].to_s }.join(' ')
        end

        # Times are London time, e.g. '1830'
        def starting_at(performance, date)
          hour, minute = performance.fetch('StartTime').unpack('a2a2').map(&:to_i)
          local = Time.utc(date.year, date.month, date.day, hour, minute)
          Cinebase::London.utc(local)
        end

        def strands
          @event.fetch('Seasons', []).map { |season| CGI.unescapeHTML(season['SeasonName'].to_s) }
        end

        def title
          @title ||= CGI.unescapeHTML(@event.fetch('Title')).squeeze(' ').strip
        end

        def variant(performance)
          from_flags = FLAGS.filter_map { |flag, variant| variant if performance[flag] == YES }
          from_title = TITLE_VARIANTS.filter_map { |pattern, variant| variant if title.match?(pattern) }
          (from_flags + from_title).uniq
        end

        def year_field
          @event['Year'].to_s.strip
        end
      end
    end
  end
end

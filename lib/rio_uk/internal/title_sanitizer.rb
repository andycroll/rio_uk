module RioUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles. The Rio writes the film in
    # capitals and its strand, presenter and extras in mixed case, e.g.
    # 'Little White Lies: PAN'S LABYRINTH on 35mm'.
    class TitleSanitizer < Cinebase::TitleSanitizer
      # Event cinema names to keep in front of the film
      EVENT_CINEMA = /\A(?:NT Live|National Theatre Live|RBO|Royal Ballet|Met Opera|Exhibition on Screen)\b[^:]*:\s*/i
      # A strand or presenter that names a club, festival or presenter
      PRESENTER = /\b(?:club|fest|festival|kino|presents?)\b/i
      SMALL_WORDS = %w(a an and as at but by for from in nor of on or the to v vs via with).freeze
      # Lone Roman numerals, e.g. 'II', stay in capitals
      ROMAN = /\A(?=[IVXLC])C{0,3}(?:XC|XL|L?X{0,3})(?:IX|IV|V?I{0,3})\z/
      VOWEL = /[AEIOUYÀ-ÖØ-Ý]/
      # The first two-letter word, which says whether the title is in capitals
      FIRST_WORD = /[\p{L}\p{N}'’-]*\p{L}[\p{L}\p{N}'’-]*\p{L}[\p{L}\p{N}'’-]*/

      # Constructor
      # @param [String] title a film title, without HTML entities
      # @param [String] director the event's director, whose name some
      #   titles lead with, e.g. "Alain Gomis' DAO"
      # @param [Array<String>] strands the event's season names, e.g.
      #   'Pink Palace'
      # @return [RioUk::Internal::TitleSanitizer]
      def initialize(title, director: '', strands: [])
        super(title)
        @director = director
        @strands = strands
      end

      # sanitized and standardized title
      # @return [String] sanitised title
      def sanitized
        @sanitized ||= begin
          listed = without_director(title.squeeze(' ').strip)
          event_cinema = listed[EVENT_CINEMA].to_s
          film = without_strand(listed.delete_prefix(event_cinema))
          film = titlecase(leading_capitals(film)) if capitals?(film)
          film = remove.reduce(event_cinema + film) { |text, pattern| text.gsub(pattern, '') }
          replace.reduce(film) { |text, (pattern, prefix)| text.gsub(pattern) { prefix + $1 } }.squeeze(' ').strip
        end
      end

      private

      # strings and regex to be removed
      def remove
        [/[\s:,+-]+\z/] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        {
          /\A(?:NT|National Theatre) Live:\s*(.*)/i              => 'National Theatre Live: ',
          /\ARBO (?:Cinema Season )?20\d{2}-\d{2}:\s*(.*)/i      => 'Royal Ballet and Opera: ',
          /\AExhibition on Screen:\s*(.*)/i                      => 'Exhibition on Screen: '
        }.merge(COMMON_REPLACE)
      end

      def capitals?(text)
        word = text[FIRST_WORD]
        !word.nil? && !word.match?(/\p{Ll}/)
      end

      # Mixed case words after the film are extras, e.g. 'on 35mm'
      def leading_capitals(text)
        text.split(' ').take_while { |word| !word.match?(/\p{Ll}/) }.join(' ')
      end

      def without_director(text)
        if @director.empty?
          text
        else
          text.sub(/#{Regexp.escape(@director)}['’]s?\s+(?=\S)/i, '')
        end
      end

      # The first prefix before a colon goes when it is one of the event's
      # strands, names a club, festival or presenter, or is in mixed case in
      # front of a film in capitals
      def without_strand(text)
        prefix, film = text.split(/:\s+/, 2)
        if film.nil?
          text.sub(/\A.+?\s+presents\s+/i, '')
        elsif strand?(prefix) || prefix.match?(PRESENTER) || (prefix.match?(/\p{Ll}/) && capitals?(film))
          film
        else
          text
        end
      end

      def strand?(prefix)
        @strands.any? { |strand| prefix.downcase.start_with?(strand.downcase) }
      end

      # Words start with a capital, except small words inside the title
      def titlecase(text)
        text.gsub(/[\p{L}\p{N}'’]+/) do |word|
          titlecase_word(word, first: $`.match?(/\A[^\p{L}\p{N}]*\z|[:(–-]\s*\z/))
        end
      end

      def titlecase_word(word, first:)
        if !first && SMALL_WORDS.include?(word.downcase)
          word.downcase
        elsif word.match?(/\p{N}|\p{Ll}/) || word.length < 2 || word.match?(ROMAN) || !word.match?(VOWEL)
          word
        else
          word.capitalize
        end
      end
    end
  end
end

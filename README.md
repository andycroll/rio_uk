# RioUk

A simple gem to pull the cinema and its performances from the [Rio Cinema website](https://riocinema.org.uk) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'rio_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rio_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

No token or setup is needed. The website runs on Savoy Systems' ticketing.
Every page of it carries the whole programme as one line of JSON, every event
on sale with every advertised performance, so one request to the what's on
page reads it all. There is no lighter feed and no compression; the page is
about 850 KB.

### Cinema

The Rio is one venue, keyed `rio`, the name of its Savoy site. The gem holds
its details: the address from the website's footer and coordinates from
OpenStreetMap. Cinema methods make no requests.

``` ruby
RioUk::Cinema.all
#=> [<RioUk::Cinema ...>]

cinema = RioUk::Cinema.new('rio')
#=> <RioUk::Cinema ...>

cinema.adr
#=> {
  street_address:   '107 Kingsland High Street',
  extended_address: nil,
  locality:         'London',
  region:           nil,
  postal_code:      'E8 2PB',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Independent'

cinema.name
#=> 'Rio Cinema'

cinema.id
#=> 'rio'

cinema.latitude
#=> 51.5496199

cinema.url
#=> 'https://riocinema.org.uk'
```

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days. Any range is one
request.

``` ruby
RioUk::Performance.at('rio', from: Date.today, to: Date.today + 365)
#=> [<RioUk::Performance ...>, <RioUk::Performance ...>, ...]

performance = RioUk::Performance.at('rio').first
#=> <RioUk::Performance ...>

performance.film_name
#=> 'Dao' # from "Black History Month:  Alain Gomis' DAO"

performance.film_year
#=> nil

performance.dimension
#=> '2d'

performance.variant
#=> ['q&a']

performance.starting_at
#=> 2026-11-01 13:30:00 UTC

performance.booking_url
#=> 'https://riocinema.org.uk/Rio.dll/Booking?Booking=TSelectItems.waSelectItemsPrompt.TcsWebMenuItem_0.TcsWebTab_0.TcsPerformance_2884892.TcsSection_1299'

performance.cinema_name
#=> 'Rio Cinema'

performance.cinema_id
#=> 'rio'
```

Booking links open Savoy's ticket selection for the performance. A few special
events sell through a partner, such as the Japanese Film Club, and link there.
Sold out performances are listed with no booking link.

Variants come from the Rio's performance flags and from titles: `baby` (Carers
+ Baby), `senior` (Classic Matinee, for the over 60s), `kids` (Family Flicks
and Hackney Children's Film Fest), `subtitled` (Hard of Hearing), `q&a`,
`relaxed`, `35mm`, `70mm` and `sing_along`. Pink Palace, Rio Forever, special
event and no ads flags are not variants.

Film years come from the listing's year, or a year in the title. Double bills
('1974 / 1976') and programmes ('Various') have none.

Only films are kept: events whose type names a film or feature and that have a
director or a year. Gigs and parties listed as films, such as 'Velcro Flats
presents POZI', have neither.

Titles are cleaned up. The Rio writes the film in capitals and everything else
in mixed case:

- Strands, clubs, festivals and presenters before a colon go: 'Pink Palace: A
  SINGLE MAN', 'JAPANESE FILM CLUB: YOUR NAME', 'Loose Willis presents: THE
  DEVILS'.
- A mixed case prefix before a film in capitals goes: 'Category H: MALATESTA’S
  CARNIVAL OF BLOOD + FINAL DESTINATION 3'.
- Mixed case extras after a film in capitals go: 'PAN'S LABYRINTH on 35mm',
  'WE, THE HATED (Just Stop Oil doc) + Q&A', '... with Smut Press'.
- A director's name in front goes: "Alain Gomis' DAO" becomes 'Dao'.
- Capitals become title case: 'SHAUN THE SHEEP: THE BEAST OF MOSSY BOTTOM'
  becomes 'Shaun the Sheep: The Beast of Mossy Bottom'. Words with digits,
  Roman numerals and words without vowels, such as 'M3GAN', 'II' and 'RRR',
  keep their capitals.
- Event cinema names stay and are standardised: 'NT Live: HAMLET' becomes
  'National Theatre Live: Hamlet', 'RBO 2026-27: SWAN LAKE' becomes 'Royal
  Ballet and Opera: Swan Lake'.

Double bills keep both films: 'Flesh Gordon + Gums'.

## Tests

```sh
bundle exec rake                # unit tests against fixtures
LIVE=1 bundle exec rake live    # live riocinema.org.uk
```

The fixture in `test/fixtures` is the what's on page, trimmed to its programme
of a few events with short synopses. `test/support/api_shapes.rb` describes
the JSON the gem reads. The unit suite checks the fixture against it and the
live suite checks the real page, held only in memory. When the page changes,
update the shape first, then the fixture.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

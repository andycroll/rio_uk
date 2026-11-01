require 'cgi/escape'
require 'json'

require 'cinebase'

require_relative './rio_uk/version'

require_relative './rio_uk/internal/http'
require_relative './rio_uk/internal/website'
require_relative './rio_uk/internal/title_sanitizer'
require_relative './rio_uk/internal/parser/event'

require_relative './rio_uk/cinema'
require_relative './rio_uk/performance'

# rio_uk gem
module RioUk
end

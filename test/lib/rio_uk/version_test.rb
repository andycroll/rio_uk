require_relative '../../test_helper'

class RioUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil RioUk::VERSION
  end
end

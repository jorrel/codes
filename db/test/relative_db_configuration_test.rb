require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'relative_db_configuration')


class RelativeDBConfigurationTest < Test::Unit::TestCase
  def setup
    with_warnings_suppressed {
      RelativeDBConfiguration.const_set(:CurrentPath, File.dirname(__FILE__))
    }
    @default = RelativeDBConfiguration.new
  end

  def test_override_the_current_path_for_testing
    assert_equal File.dirname(__FILE__), RelativeDBConfiguration::CurrentPath
  end

  def test_config_path
    assert_equal File.join(File.dirname(__FILE__), 'config/database.yml'), @default.config_path
  end

  def test_default_environment
    assert_equal RelativeDBConfiguration::DefaultEnvironment, @default.environment
  end

  def test_default_config_fetched
    assert_kind_of Hash, @default.configuration
    puts @default.inspect
    assert_equal 'mysql', @default.configuration[:database]
  end

  private

    # Suppresses warnings within a given block.
    # http://textsnippets.com/posts/show/1438
    def with_warnings_suppressed
      saved_verbosity = $-v
      $-v = nil
      yield
    ensure
      $-v = saved_verbosity
    end
end
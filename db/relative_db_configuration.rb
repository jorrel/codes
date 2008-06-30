require 'yaml'

class RelativeDBConfiguration

  RelativeDatabaseConfigPath = 'config/database.yml'
  DefaultEnvironment = :development
  CurrentPath = Dir.pwd

  attr_accessor :environment, :configuration

  def initialize(environment = DefaultEnvironment)
    @environment = environment.to_sym
    fetch_configuration
  end

  def config_path
    File.join(CurrentPath, RelativeDatabaseConfigPath)
  end

  private

    def fetch_configuration
      @configuration = YAML.load_file(
                            File.join(CurrentPath, RelativeDatabaseConfigPath)
                           ).recursively_symbolize_keys[@environment]
    end

end

class Hash
  def recursively_symbolize_keys
    inject({}) { |h, (k, v)| h[k.to_sym] = v.is_a?(Hash) ? v.recursively_symbolize_keys : v; h }
  end
end
require 'yaml'

class Queryer

  # queryer will attempt to fetch this file relative to the
  # current working directory to get the default configuration
  DatabaseConfigLocation = "config/database.yml"

  # the default relational database to use if adapter is not
  # provided and no database config file is loaded
  DefaultAdapter = 'mysql'

  attr_reader :config

  def initialize(config = nil)
    if config
      @config = config
    else
      config_file = File.join(Dir.pwd, DatabaseConfigLocation)
      if File.exists?(config_file)
        config = YAML.load_file(config_file).recursively_symbolize_keys
        @config = config && config[:development]
      end
    end
    @config ||= {}
  end

  def perform(query)
    puts "config: #{config.inspect}" if debug?
    queryer.perform(query)
  end

  def debug?
    !!config[:debug]
  end

  def default(what)
    config[what.to_sym] || nil
  end

  def override_config(new_config = {})
    @config.merge! new_config.recursively_symbolize_keys
  end

  def queryer
    case config[:adapter] || DefaultAdapter
    when 'mysql' then MysqlQueryer.new(config)
    else raise "Unknown adapter: #{config[:adapter]}"
    end
  end
end

class MysqlQueryer < Queryer
  def perform(query)
    command = "mysql #{flags} -e \"#{query}\""
    puts command if debug?
    system(command)
  end

  def flags
    fl = "-u #{config[:username] || 'root'}"
    fl << " -h #{config[:hostname]}" unless config[:hostname].nil? or config[:hostname].empty?
    fl << " -p#{config[:password]}" unless config[:password].nil? or config[:password].empty?
    fl << " #{config[:database] || 'mysql'}"
    fl
  end
end

class Hash
  def recursively_symbolize_keys
    inject({}) { |h, (k, v)| h[k.to_sym] = v.is_a?(Hash) ? v.recursively_symbolize_keys : v; h }
  end
end
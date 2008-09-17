require 'yaml'
require 'erb'

class Queryer

  # queryer will attempt to fetch this file relative to the
  # current working directory to get the default configuration
  DatabaseConfigLocation = "config/database.yml"

  # the default relational database to use if adapter is not
  # provided and no database config file is loaded
  DefaultAdapter = 'mysql'

  # default environment
  DefaultEnvironment = 'development'

  attr_reader :config, :environment

  def initialize(config = nil, environment = nil)
    @environment = (environment || DefaultEnvironment).to_sym
    if config
      @config = config
    else
      config_file = File.join(Dir.pwd, DatabaseConfigLocation)
      if File.exists?(config_file)
        config = YAML.load(ERB.new(IO.read(config_file)).result).recursively_symbolize_keys
        @config = config && config[@environment]
      end
    end
    @config ||= {}
  end

  def perform(query)
    if debug?
      puts "environment: #{environment}"
      puts "config: #{config.inspect}"
    end
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
    when 'mysql'   then MysqlQueryer.new(config, @environment)
    when 'sqlite3' then Sqlite3Queryer.new(config, @environment)
    else raise "Unknown adapter: #{config[:adapter]}"
    end
  end

  def system_with_logging(command)
    puts command if debug?
    system_without_logging(command)
  end

  alias :system_without_logging :system
  alias :system :system_with_logging
end

class MysqlQueryer < Queryer
  def perform(query)
    system "mysql #{flags} -e \"#{query}\""
  end

  def flags
    fl = "-u #{config[:username] || 'root'}"
    fl << " -h #{config[:hostname]}" unless config[:hostname].nil? or config[:hostname].empty?
    fl << " -p#{config[:password]}" unless config[:password].nil? or config[:password].empty?
    fl << " #{config[:database] || 'mysql'}"
    fl
  end
end

class Sqlite3Queryer < Queryer
  def perform(query)
    system "sqlite3 #{config[:database]} \"#{query}\""
  end
end

class Hash
  def recursively_symbolize_keys
    inject({}) { |h, (k, v)| h[k.to_sym] = v.is_a?(Hash) ? v.recursively_symbolize_keys : v; h }
  end
end
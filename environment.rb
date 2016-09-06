$:.unshift File.dirname(__FILE__)
env = (ENV['RACK_ENV'] || :development)

require 'bundler'
Bundler.require :default, env.to_sym

Dotenv.load if defined?(Dotenv)

require 'grape'
require 'active_support/all'
require 'oj'

module Application
  include ActiveSupport::Configurable

  def self.relative_load_paths
    %w[ app app/api app/api/**/* app/api/* ]
  end

  def self.eager_load!
    relative_load_paths.each do |load_path|
      matcher = /\A#{Regexp.escape(load_path.to_s)}\/(.*)\.rb\Z/
      Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
        require_dependency file.sub(matcher, '\1')
      end
    end
  end

  def self.load_tasks
    Dir['lib/tasks/**/*.rake'].each { |f| load f }
  end
end

# General application configuration
Application.configure do |config|
  config.root      = File.dirname(__FILE__)
  config.env       = ActiveSupport::StringInquirer.new(env.to_s)
  config.time_zone = 'Brasilia'

  # Configure Oj float precision
  oj_default_opts = Oj.default_options
  oj_default_opts[:float_precision] = 17
  Oj.default_options = oj_default_opts
end

# Time configuration
Time.zone = Application.config.time_zone

# Encoding
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Auto loading stuff
ActiveSupport::Dependencies.autoload_paths += Application.relative_load_paths

# Per-environment configuration
specific_environment = "#{Application.config.root}/config/environments/#{Application.config.env}.rb"
require specific_environment if File.exists?(specific_environment)

Dir['config/initializers/**/*.rb'].each { |f| require f }

$LOAD_PATH.unshift File.dirname(__FILE__)
env = (ENV['RACK_ENV'] || :development)

require 'bundler'
Bundler.require :default, env.to_sym

Dotenv.load if defined?(Dotenv)

require 'grape'
require 'active_support/all'
require 'active_record'
require 'oj'
require 'i18n'

module Application
  include ActiveSupport::Configurable

  def self.relative_load_paths
    %w(app app/models app/models/**/* app/services app/services/**/*app/api app/api/**/* app/api/*)
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
ActiveRecord::Base.time_zone_aware_attributes = true
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.schema_format = :sql

# Database configuration
database_file = "#{Application.config.root}/config/database.yml"
if File.exist?(database_file)
  ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read(database_file)).result)
  DB_CONNECTION_CONFIG = ActiveRecord::Base.configurations[Application.config.env]
else
  DB_CONNECTION_CONFIG = ENV['DATABASE_URL']
end

ActiveRecord::Base.establish_connection(DB_CONNECTION_CONFIG)

# Encoding
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Language
I18n.load_path = Dir[File.join(Application.config.root, 'config', 'locales', '*.yml')]
I18n.backend.load_translations
I18n.locale = :'pt-BR'
I18n.default_locale = :'pt-BR'

# Auto loading stuff
ActiveSupport::Dependencies.autoload_paths += Application.relative_load_paths

# Per-environment configuration
specific_environment = "#{Application.config.root}/config/environments/#{Application.config.env}.rb"
require specific_environment if File.exist?(specific_environment)

Dir['config/initializers/**/*.rb'].each { |f| require f }

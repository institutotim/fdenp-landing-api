ruby '2.2.1'

source 'https://rubygems.org'

gem 'grape',                          '0.14.0'
gem 'grape-middleware-logger'
gem 'activesupport',                  '4.2.3'
gem 'activerecord',                   '4.2.3'
gem 'pg'
gem 'foreman',                        '0.78.0'
gem 'dotenv',                         '2.0.2'
gem 'oj',                             '2.12.12'
gem 'rest-client',                    '1.8.0'
gem 'grape-swagger',                  '0.10.2'
gem 'geocoder',                       '1.2.9'
gem 'sentry-raven'
gem 'i18n'

group :development do
  gem 'passenger',                    '5.0.15'
end

group :development, :test do
  gem 'rack-test',                    '0.6.3', require: 'rack/test'
  gem 'rspec',                        '3.3.0'
  gem 'awesome_print',                '1.6.1'
  gem 'pry-byebug',                   '3.2.0'
  gem 'pry-remote',                   '0.1.8'
end

group :test do
  gem 'vcr',                          '2.9.3'
  gem 'webmock',                      '1.21.0' # because of vcr
  gem 'database_rewinder',            require: false
end

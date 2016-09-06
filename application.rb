require File.expand_path('../environment', __FILE__)

module ZupApi
end

ZupServer = Rack::Builder.new do
  map '/' do
    run API::Base
  end
end

require 'oj'

module API
  class Base < Grape::API
    logger = Logger.new('production.log')
    use Grape::Middleware::Logger, logger: logger

    format :json

    helpers do
      def logger
        Grape::API.logger
      end
    end

    rescue_from :all do |e|
      Raven.capture_exception(e)

      fail(e) if ENV['RAISE_ERRORS']

      Grape::API.logger.error(e)

      rack_response("{ \"error\": \"#{e.message}\", \"type\": \"unknown\" }", 422)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      res = { error: {}, type: 'params' }

      fail(e) if ENV['RAISE_ERRORS']

      e.errors.each do |field_name, error|
        res[:error].merge!(field_name[0] => error.map(&:to_s))
      end

      rack_response(res.to_json, 422)
    end

    desc 'Receives callback from SMS broker'
    post '/callback/zenvia' do
      logger.info(params.inspect)
      ZenviaReceiver.new(params).process!

      {
        message: 'Relato criado com sucesso'
      }
    end

    mount API::V1::Base
    add_swagger_documentation(hide_format: true)
  end
end

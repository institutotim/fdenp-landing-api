module API
  module V1
    class Base < Grape::API
      use Grape::Middleware::Logger

      prefix :v1

      helpers do
        def logger
          Grape::API.logger
        end
      end

      mount API::V1::Reports
    end
  end
end

require 'oj'

module API
  class Base < Grape::API
    format :json

    mount API::V1::Base
    add_swagger_documentation(hide_format: true)
  end
end

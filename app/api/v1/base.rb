module API
  module V1
    class Base < Grape::API
      prefix :v1

      mount API::V1::Reports
    end
  end
end

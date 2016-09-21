require 'rest-client'
require 'geocoder'

module API
  module V1
    class Reports < Grape::API
      resource :reports do
        rescue_from Grape::Exceptions::ValidationErrors do |e|
          res = { error: {}, type: 'params' }

          e.errors.each do |field_name, error|
            res[:error].merge!(field_name[0] => error.map(&:to_s))
          end

          rack_response(res.to_json, 422)
        end

        desc 'Creates a new child report'
        params do
          requires :user_email, type: String, desc: 'The user\'s email'
          requires :reportee_name, type: String, desc: "Child's name"
          requires :address, type: String, desc: "Child's address"
          requires :district, type: String, desc: "Child's neighborhood"
          requires :probable_cause, type: Integer, desc: 'ID of the probable cause'
          optional :number, type: String, desc: "Child's address number"
          optional :reportee_birthdate, type: String, desc: "Child's birthday date"
          optional :reportee_mother_name, type: String, desc: "Child's mother name"
          optional :reference, type: String, desc: "Reference to the child's address"
        end
        post do
          message = CreateReport.new(params).create!

          if message[:error]
            status 422
            message
          else
            {
              message: 'Relato criado com sucesso'
            }
          end
        end
      end
    end
  end
end

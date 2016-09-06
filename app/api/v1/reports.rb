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
          report_category_id = params[:probable_cause]

          # Creates the report
          zup_api_create_report_url = "#{ENV['ZUP_API_URL']}/reports/#{report_category_id}/items"
          zup_api_search_user_by_email_url = "#{ENV['ZUP_API_URL']}/search/users?email=#{params[:user_email]}"

          # Search user by email
          user_search_response = RestClient.get(
            zup_api_search_user_by_email_url,
            content_type: :json,
            accept: :json,
            'X-App-Token' => ENV['ZUP_API_TOKEN']
          )

          logger.info(user_search_response.body)

          user_search = Oj.load(user_search_response.body)

          # Return error
          if user_search['users'].nil? || user_search['users'].blank?
            return { error: 'Usuário não encontrado' }
          end

          user = user_search['users'].first

          full_address = "#{params[:address]} #{params[:number]}, #{params[:district]}, #{user['city']}, Brasil"
          coordinates = Geocoder.coordinates(full_address)

          report_params = params
          report_params['description'] = 'Enviado pelo formulário online do Criança Fora da Escola Não Pode!'
          report_params['latitude'] = coordinates[0]
          report_params['longitude'] = coordinates[1]

          begin
            create_report_response = RestClient.post(
              zup_api_create_report_url,
              report_params.to_json,
              content_type: :json,
              accept: :json,
              'X-App-Token' => ENV['ZUP_API_TOKEN']
            )
          rescue RestClient::ExceptionWithResponse => err
            logger.info(err.response)
            return { error: "Erro ao criar o relato Entre em contato com o suporte técnico." }
          end


          logger.info(create_report_response.body)

          # Creates case
          zup_api_create_case_url = "#{ENV['ZUP_API_URL']}/cases"
          initial_flow_id = ENV['ZUP_API_FLOW_ID']

          case_fields = []
          case_fields << { id: ENV['ZUP_API_CHILD_NAME_FIELD_ID'], value: params['reportee_name'] }
          case_fields << { id: ENV['ZUP_API_CHILD_MOTHER_NAME_FIELD_ID'], value: params['reportee_mother_name'] }
          case_fields << { id: ENV['ZUP_API_CHILD_BIRTHDAY_FIELD_ID'], value: params['reportee_birthdate'] }
          case_fields << { id: ENV['ZUP_API_ABANDON_CAUSE_FIELD_ID'], value: params['probable_cause'] } if params['probable_cause'].present?

          case_params = {
            initial_flow_id: initial_flow_id,
            fields: case_fields,
            responsible_user_id: params[:user_id]
          }

          # Submit case
          begin
            create_case_response = RestClient.post(
              zup_api_create_case_url,
              case_params.to_json,
              content_type: :json,
              accept: :json,
              'X-App-Token' => ENV['ZUP_API_TOKEN']
            )
          rescue RestClient::ExceptionWithResponse => err
            logger.info(err.response)
            return { error: "Erro ao criar o caso. Entre em contato com o suporte técnico." }
          end

          logger.info(create_case_response.body)

          {
            message: 'Relato criado com sucesso'
          }
        end
      end
    end
  end
end

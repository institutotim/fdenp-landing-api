class CreateReport
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def create!
    report_category_id = params[:probable_cause]

    # Creates the report
    zup_api_create_report_url = "#{ENV['ZUP_API_URL']}/reports/#{report_category_id}/items"
    zup_api_search_user_by_email_url = "#{ENV['ZUP_API_URL']}/users?email=#{params[:user_email]}&ignore_namespaces=true&filter=true"

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
      return { error: 'Usuário não cadastrado. Entre em contato com o seu supervisor.', type: 'not_found' }
    end

    user = user_search['users'].first

    full_address = "#{params[:address]} #{params[:number]}, #{params[:district]}, #{user['city']}, Brasil"
    coordinates = Geocoder.coordinates(full_address)

    report_params = params
    report_params['description'] = 'Enviado pelo formulário online do Criança Fora da Escola Não Pode!'

    if coordinates.present?
      report_params['latitude'] = coordinates[0]
      report_params['longitude'] = coordinates[1]
    end

    report_params['user_id'] = user['id']
    report_params['custom_fields'] = {
      ENV['ZUP_API_CHILD_NAME_FIELD_ID'] => params['reportee_name'],
      ENV['ZUP_API_CHILD_MOTHER_NAME_FIELD_ID'] => params['reportee_mother_name'],
      ENV['ZUP_API_CHILD_BIRTHDAY_FIELD_ID'] => params['reportee_birthdate']
    }

    logger.info(report_params.to_json)

    begin
      create_report_response = RestClient.post(
        zup_api_create_report_url,
        report_params.to_json,
        content_type: :json,
        accept: :json,
        'X-App-Token' => ENV['ZUP_API_TOKEN'],
        'X-App-Namespace' => user['namespace']['id']
      )
    rescue RestClient::ExceptionWithResponse => err
      logger.error(err.response)
      return { error: 'Erro ao enviar o alerta, entre em contato com o suporte técnico.', type: 'integration' }
    end

    logger.info(create_report_response.body)

    {}
  end

  private

  def logger
    Grape::API.logger
  end
end

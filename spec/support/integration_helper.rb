module IntegrationHelper
  def parsed_body
    Oj.load(response.body)
  end
end

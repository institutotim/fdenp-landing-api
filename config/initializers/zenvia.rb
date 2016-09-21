class Zenvia
  URL = 'https://api-rest.zenvia360.com.br/services/send-sms'
  AUTHENTICATION = ENV['ZENVIA_AUTH']
  FROM = ENV['ZENVIA_FROM']

  def self.send_sms(text, number)
    params = {
      "sendSmsRequest": {
        "from": FROM,
        "to": number.to_s,
        "msg": text,
        "callbackOption": 'NONE',
        "aggregateId": '12162'
      }
    }

    headers = {
      'Authorization' => "Basic #{AUTHENTICATION}",
      content_type: :json,
      accept: :json
    }

    RestClient.post(
      URL,
      params.to_json,
      headers
    )
  rescue => e
    Raven.capture_exception(e)
    e
  end
end

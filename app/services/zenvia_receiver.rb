# Example of request:
# "callbackMoRequest": {
#   "id": "20690090",
#   "mobile": "555191951711",
#   "shortCode": "40001",
#   "account": "lafabbrica",
#   "body": "Conteudo do SMS respondido",
#   "received": "2014-08-26T12:27:08.488-03:00",
#   "correlatedMessageSmsId": "hs765939061"
# }
#
class ZenviaReceiver
  attr_reader :params

  def initialize(params)
    @params = params[:callbackMoRequest]
  end

  def process!
    ActiveRecord::Base.transaction do
      conversation = create_conversation!
      create_message!(conversation)
      FormFlow.new(conversation).process!
    end
  end

  def create_conversation!
    if message_received_at < Conversation::SESSION_WINDOW.ago
      fail 'Conversation too old to be created'
    end

    Conversation.unexpired.started.create_with(
      last_received_message_at: message_received_at
    ).find_or_create_by!(number: params[:mobile])
  end

  def create_message!(conversation)
    Message.create_with(
      body: params[:body],
      conversation: conversation,
      raw_data: params.as_json,
      received_at: message_received_at
    ).find_or_create_by!(broker_id: params[:id])
  end

  private

  def message_received_at
    Time.parse(params[:received])
  end
end

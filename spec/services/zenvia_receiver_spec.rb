require 'spec_helper'

describe ZenviaReceiver do
  describe '#process!' do
    let(:params) do
      {
        callbackMoRequest: {
          id: '20690090',
          mobile: '555191951711',
          shortCode: '40001',
          account: 'lafabbrica',
          body: 'Conteudo do SMS respondido',
          received: 1.minute.ago.iso8601,
          correlatedMessageSmsId: 'hs765939061'
        }
      }.with_indifferent_access
    end

    subject { described_class.new(params) }

    context 'new conversation' do
      it 'creates a new conversation' do
        subject.process!
        conversation = Conversation.last
        expect(conversation).to be_present
        expect(conversation.number).to eq(params[:callbackMoRequest][:mobile])
      end

      it 'creates a new message' do
        subject.process!
        message = Message.last
        expect(message).to be_present
        expect(message.conversation).to be_present
        expect(message.raw_data).to match(params[:callbackMoRequest].as_json)
        expect(message.body).to eq(params[:callbackMoRequest][:body])
        expect(message.received_at).to eq(Time.parse(params[:callbackMoRequest][:received]))
      end
    end

    context 'existing conversation' do
      let!(:conversation) do
        Conversation.create(
          number: params[:callbackMoRequest][:mobile],
          last_received_message_at: 1.minute.ago
        )
      end

      it "doesn't create a new conversation" do
        subject.process!
        expect(Conversation.all.to_a).to eq([conversation])
      end

      context 'expired conversation' do
        before do
          conversation.update(last_received_message_at: 25.hours.ago)
        end

        it 'creates a new conversation' do
          subject.process!
          expect(Conversation.count).to eq(2)
        end
      end
    end
  end
end

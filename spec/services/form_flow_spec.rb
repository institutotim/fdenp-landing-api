require 'spec_helper'

describe FormFlow do
  let(:conversation) do
    Conversation.create(
      number: '1155941774986'
    )
  end
  let(:first_message) do
    conversation.messages.create(
      broker_id: 1,
      body: 'fdenp',
      received_at: Time.now,
      raw_data: { body: 'fdenp' }
    )
  end
  let(:first_answer) do
    conversation.messages.create(
      broker_id: 2,
      body: 'fdenp S',
      received_at: Time.now,
      raw_data: { body: 'fdenp' }
    )
  end
  let(:second_answer) do
    conversation.messages.create(
      broker_id: 2,
      body: 'fdenp test@example.com',
      received_at: Time.now,
      raw_data: { body: 'fdenp test@example.com' }
    )
  end
  let(:create_all_questions) do
    first_message.update!(step: -1, valid_message: true)
    (0..5).each do |idx|
      conversation.messages.create(
        step: idx,
        broker_id: 2,
        body: 'fdenp test',
        received_at: Time.now,
        valid_message: true,
        raw_data: { body: 'fdenp test' }
      )
    end
  end
  let(:category_code_question) do
    conversation.messages.create(
      broker_id: 2,
      body: 'fdenp 12',
      received_at: Time.now,
      raw_data: { body: 'fdenp 12' }
    )
  end
  let(:reset_answer) do
    conversation.messages.create(
      broker_id: 2,
      body: 'fdenp sair',
      received_at: Time.now,
      raw_data: { body: 'fdenp sair' }
    )
  end

  subject { described_class.new(conversation) }

  before do
    allow(subject).to receive(:send_sms).and_return(true)
    allow_any_instance_of(CreateReport).to receive(:create!).and_return(true)
  end

  context 'first message received' do
    it 'sends the first question' do
      first_message
      subject.process!
      expect(subject).to have_received(:send_sms).with(described_class::STEPS.first[:question])
    end
  end

  context 'first question' do
    context 'first question answered' do
      before do
        first_message.update(step: -1)
        first_answer
      end

      it 'sends the second question' do
        subject.process!
        expect(subject).to have_received(:send_sms).with(described_class::STEPS[1][:question])
      end
    end

    context 'first question answered with negative answer' do
      before do
        first_message.update(step: -1)
        first_answer.update!(body: 'fdenp n')
      end

      it 'finishes conversation' do
        subject.process!
        expect(conversation.reload).to be_finished
      end
    end

    context 'first question answered other than yes' do
      before do
        first_message.update(step: -1)
        first_answer.update!(body: 'fdenp nao')
      end

      it 'resend same question' do
        subject.process!
        expect(subject).to have_received(:send_sms).with("Resposta inválida, por favor responda novamente: Você gostaria de enviar um alerta ao Fora da escola não pode? (S/N)")
      end
    end
  end

  context 'second question' do
    before do
      first_message.update(step: -1)
      first_answer.update(step: 0)
      second_answer
    end

    it 'sends the second question' do
      subject.process!
      expect(subject).to have_received(:send_sms).with(described_class::STEPS[2][:question])
    end
  end

  context 'category code question' do
    before do
      create_all_questions
      category_code_question

      allow_any_instance_of(CreateReport).to receive(:create!).and_return(true)
    end

    it 'validates the category code question' do
      subject.process!
      expect(subject).to have_received(:send_sms).with('Recebemos seu alerta com sucesso, obrigado.')
    end
  end

  context 'sending all codes to user' do
    before do
      (-1..4).each do |idx|
        conversation.messages.create(
          step: idx,
          broker_id: 2,
          body: 'fdenp test',
          received_at: Time.now,
          valid_message: true,
          raw_data: { body: 'fdenp test' }
        )
      end

      conversation.messages.last.update(valid_message: nil)
    end

    it 'sends the user all the codes' do
      expect(subject).to receive(:send_sms).with(FormFlow::STEPS[6][:question])
      subject.process!
    end
  end

  context 'reset command' do
    before do
      (-1..3).each do |idx|
        conversation.messages.create(
          step: idx,
          broker_id: 2,
          body: 'fdenp test',
          received_at: Time.now,
          valid_message: true,
          raw_data: { body: 'fdenp test' }
        )
      end
      reset_answer
    end

    it 'finishes conversation' do
      expect(conversation).to be_present
      expect(subject).to receive(:send_sms).with('Você pode enviar um novo alerta novamente enviando a palavra-chave para este número.')
      subject.process!

      con = Conversation.find_by(id: conversation.id)
      expect(con).to be_finished
    end
  end

  context 'last question is answered' do
    before do
      (-1..FormFlow::STEPS.size - 1).each do |idx|
        conversation.messages.create(
          step: idx,
          broker_id: 2,
          body: 'fdenp test',
          received_at: Time.now,
          valid_message: true,
          raw_data: { body: 'fdenp test' }
        )
      end
    end

    it 'finishes the conversation' do
      subject.process!
      expect(conversation.reload).to be_finished
    end
  end
end

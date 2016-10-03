# This class coordinates all possible interactions with users
# * Sends questions SMS to the user's number
# * Resets the entire flow
# * Validates questions
# * Creates the report if everything's ok
class FormFlow
  SHORT_CODE = ENV['ZENVIA_SHORTCODE']

  COMMANDS = {
    'sair' => :reset_conversation
  }

  CATEGORIES_CODES = {
    1  => 'Adolescente em conflito com a lei',
    2  => 'Criança ou adolescente com deficiência(s)',
    3  => 'Criança ou adolescente com doença(s) que impeça(m) ou dificulte(m) a frequência à escola',
    4  => 'Criança e adolescente situação de rua',
    5  => 'Criança ou adolescente em vítima de abuso / violência sexual',
    6  => 'Crianças ou adolescente em abrigo',
    7  => 'Evasão porque sente a escola desinteressante',
    8  => 'Falta de documentação da criança ou adolescente',
    9  => 'Falta de infraestrutura escolar',
    10  => 'Falta de transporte escolar',
    11 => 'Gravidez na adolescência',
    12 => 'Preconceito ou discriminação racial',
    13 => 'Trabalho infantil',
    14 => 'Violência familiar',
    15 => 'Violência na escola',

  }

  CATEGORIES_MAPPING = {
    1  => 15,
    2  => 7,
    3  => 8,
    4  => 21,
    5  => 11,
    6  => 14,
    7  => 5,
    8  => 4,
    9  => 1,
    10 => 16,
    11 => 9,
    12 => 12,
    13 => 13,
    14 => 10,
    15 => 2,

  }

  STEPS = [
    {
      question: 'Você gostaria de enviar um alerta ao Fora da escola não pode? (S/N)',
      confirmation: true
    },
    {
      question: 'Qual o seu e-mail de cadastro?'
    },
    {
      question: 'Qual o nome completo da criança?'
    },
    {
      question: 'Qual o nome completo da mãe ou responsável?'
    },
    {
      question: 'Qual o logradouro do endereço?'
    },
    {
      question: 'Qual o bairro?'
    },
    {
      question: 'Qual a possível causa da criança estar fora da escola?',
      validation: :validate_category_code
    }
  ]

  attr_reader :conversation

  def initialize(conversation)
    @conversation = conversation
  end

  def process!
    if current_step.nil?
      last_message.update(valid_message: true, step: -1)
      send_next_question!

      return true
    end

    validate_last_message!
    create_report_if_valid!
  end

  # If the conversation satisfies, create report
  def create_report_if_valid!
    messages = conversation.messages.valid.where.not(step: nil).group(:step)

    if messages.size.size == STEPS.size + 1
      messages = conversation.messages.valid.where.not(step: nil).group_by(&:step)

      params = {
        user_email: remove_short_code(messages[1].first.body),
        reportee_name: remove_short_code(messages[2].first.body),
        reportee_mother_name: remove_short_code(messages[3].first.body),
        address: remove_short_code(messages[4].first.body),
        district: remove_short_code(messages[5].first.body),
        probable_cause: CATEGORIES_MAPPING[remove_short_code(messages[6].first.body).to_i]
      }

      # Creates the report and notifies the user
      CreateReport.new(params.with_indifferent_access).create!
      conversation.finished!
      send_sms('Recebemos seu alerta com sucesso, obrigado.')
    end
  end

  # Validates last user response, if valid, sends next question
  def validate_last_message!
    return unless last_message

    message_content = remove_short_code(last_message.body).strip
    return if validate_command!(message_content)

    step = STEPS[current_step + 1]

    validation_passed = false
    if step[:validation]
      validation_passed = send(step[:validation], message_content)
    elsif !message_content.blank? || step[:validation] === false
      validation_passed = true
    end

    if validation_passed
      last_message.update(valid_message: true, step: current_step + 1)

      if step[:confirmation]
        if message_content.downcase == 's'
          send_next_question!

          true
        elsif message_content.downcase == 'n'
          conversation.finished!
          send_sms('Você pode enviar um novo alerta novamente enviando a palavra-chave para este número.')

          false
        else
          resend_current_question!

          false
        end
      else
        send_next_question!

        true
      end
    else
      last_message.update(valid_message: false, step: current_step + 1)
      resend_current_question!

      true
    end
  end

  def send_next_question!
    unless has_next_question?
      conversation.finished!
      return false
    end

    # If it's the category code, sends all the code to user
    if (current_step + 1) == 6
      categories_codes_msg.each do |msg|
        send_sms(msg.to_s)
      end
    end

    question = STEPS[current_step + 1][:question]
    send_sms(question)
  end

  def has_next_question?
    STEPS[current_step + 1].present?
  end

  def categories_codes_msg
    array = []

    msg = "Códigos de causa disponíveis:\n"
    CATEGORIES_CODES.each do |code, text|
      category_msg = "#{code}. #{text}\n"

      if (msg + category_msg).size > 130
        array << msg
        msg = category_msg
      else
        msg += category_msg
      end
    end

    array << msg
    array
  end

  def resend_current_question!
    question = STEPS[current_step][:question]
    send_sms("Resposta inválida, por favor responda novamente: #{question}")
  end

  def send_sms(text)
    Zenvia.send_sms(text, conversation.number)
  end

  def last_message
    @last_message ||= conversation.messages.not_validated.last
  end

  # The question to ask now
  def current_step
    fail 'Conversation without messages' if conversation.messages.count == 0

    # If the all messages in a conversation doesn't have a step,
    # it's the first interaction
    conversation.messages.where.not(step: nil).order(step: :desc).try(:first).try(:step)
  end

  def validate_command!(message_content)
    COMMANDS.each do |command, method|
      if message_content.downcase == command.downcase
        send(method) and return true
      end
    end

    false
  end

  def reset_conversation
    conversation.finished!
    send_sms("Você pode enviar um novo alerta novamente enviando a palavra-chave para este número.")
  end

  private

  def validate_category_code(message_content)
    CATEGORIES_CODES[message_content.to_i].present?
  end

  def remove_short_code(string)
    string.gsub(/#{SHORT_CODE}/i, '')
  end
end

class Conversation < ActiveRecord::Base
  # After this time, the conversation will expire
  SESSION_WINDOW = 24.hours

  enum status: [:started, :finished]

  has_many :messages

  validates :number, presence: true

  scope :unexpired, -> { where('last_received_message_at > ?', SESSION_WINDOW.ago) }
end
